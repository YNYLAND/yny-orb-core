create table if not exists public.profile_balances (
  profile_id uuid primary key references public.profiles(id) on delete restrict,
  balance_yny numeric(24,8) not null default 0 check (balance_yny >= 0),
  updated_at timestamptz not null default now()
);

create table if not exists public.balance_transactions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete restrict,
  topup_order_id uuid null,
  type text not null check (type in ('topup','spend','refund','adjustment')),
  amount_yny numeric(24,8) not null,
  provider text null,
  external_transaction_id text null unique,
  description text null,
  created_at timestamptz not null default now()
);

create index if not exists balance_transactions_profile_created_idx
  on public.balance_transactions(profile_id, created_at desc);

create table if not exists public.yny_menu_offers (
  entity_key text primary key,
  display_name text not null,
  price_yny numeric(24,8) not null check (price_yny >= 0),
  currency text not null default 'YNY' check (currency = 'YNY'),
  is_active boolean not null default true,
  sale_state text not null default 'live' check (sale_state in ('live','planned','disabled')),
  repeatable boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.yny_menu_offers (
  entity_key, display_name, price_yny, currency, is_active, sale_state, repeatable, sort_order
)
values (
  'neo.profile.acaunt', 'ACAUNT', 1, 'YNY', true, 'live', false, 10
)
on conflict (entity_key) do update set
  display_name = excluded.display_name,
  price_yny = excluded.price_yny,
  currency = excluded.currency,
  is_active = excluded.is_active,
  sale_state = excluded.sale_state,
  repeatable = excluded.repeatable,
  sort_order = excluded.sort_order,
  updated_at = now();

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  owner_profile_id uuid not null unique references public.profiles(id) on delete restrict,
  entity_key text not null default 'neo.profile.acaunt' check (entity_key = 'neo.profile.acaunt'),
  status text not null default 'active' check (status in ('active','suspended','archived')),
  display_name text null,
  purchase_transaction_id uuid not null unique references public.balance_transactions(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profile_balances enable row level security;
alter table public.balance_transactions enable row level security;
alter table public.yny_menu_offers enable row level security;
alter table public.accounts enable row level security;

revoke all on table public.profile_balances from anon, authenticated;
revoke all on table public.balance_transactions from anon, authenticated;
revoke all on table public.yny_menu_offers from anon, authenticated;
revoke all on table public.accounts from anon, authenticated;

grant select, insert, update, delete on table public.profile_balances to service_role;
grant select, insert, update, delete on table public.balance_transactions to service_role;
grant select, insert, update, delete on table public.yny_menu_offers to service_role;
grant select, insert, update, delete on table public.accounts to service_role;

create or replace function public.get_profile_account_quote_v1(p_profile_id uuid)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_profile_status text;
  v_balance numeric(24,8) := 0;
  v_account public.accounts%rowtype;
begin
  if p_profile_id is null then
    return jsonb_build_object('ok', false, 'code', 'invalid_request');
  end if;

  select status into v_profile_status
  from public.profiles
  where id = p_profile_id;

  if not found then
    return jsonb_build_object('ok', false, 'code', 'profile_not_found');
  end if;

  if v_profile_status <> 'active' then
    return jsonb_build_object('ok', false, 'code', 'profile_not_active');
  end if;

  select * into v_offer
  from public.yny_menu_offers
  where entity_key = 'neo.profile.acaunt'
    and is_active = true
    and sale_state = 'live';

  if not found then
    return jsonb_build_object('ok', false, 'code', 'offer_not_available');
  end if;

  select coalesce(balance_yny, 0) into v_balance
  from public.profile_balances
  where profile_id = p_profile_id;

  if not found then
    v_balance := 0;
  end if;

  select * into v_account
  from public.accounts
  where owner_profile_id = p_profile_id;

  if found then
    return jsonb_build_object(
      'ok', true,
      'already_created', true,
      'account_id', v_account.id,
      'entity_key', v_offer.entity_key,
      'display_name', v_offer.display_name,
      'price_yny', v_offer.price_yny,
      'charge_yny', 0,
      'balance_yny', v_balance,
      'can_purchase', false
    );
  end if;

  return jsonb_build_object(
    'ok', true,
    'already_created', false,
    'entity_key', v_offer.entity_key,
    'display_name', v_offer.display_name,
    'price_yny', v_offer.price_yny,
    'charge_yny', v_offer.price_yny,
    'balance_yny', v_balance,
    'can_purchase', (v_balance >= v_offer.price_yny),
    'missing_yny', greatest(v_offer.price_yny - v_balance, 0)
  );
end;
$$;

create or replace function public.purchase_profile_account_v1(
  p_profile_id uuid,
  p_display_name text default null
)
returns jsonb
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_balance numeric(24,8) := 0;
  v_new_balance numeric(24,8);
  v_account public.accounts%rowtype;
  v_transaction_id uuid := gen_random_uuid();
  v_clean_name text;
begin
  if p_profile_id is null then
    return jsonb_build_object('ok', false, 'code', 'invalid_request');
  end if;

  v_clean_name := nullif(btrim(coalesce(p_display_name, '')), '');
  if v_clean_name is not null and length(v_clean_name) > 100 then
    return jsonb_build_object('ok', false, 'code', 'display_name_too_long');
  end if;

  perform 1
  from public.profiles
  where id = p_profile_id
    and status = 'active'
  for update;

  if not found then
    return jsonb_build_object('ok', false, 'code', 'profile_not_found_or_inactive');
  end if;

  select * into v_account
  from public.accounts
  where owner_profile_id = p_profile_id;

  if found then
    select coalesce(balance_yny, 0) into v_balance
    from public.profile_balances
    where profile_id = p_profile_id;

    return jsonb_build_object(
      'ok', true,
      'already_created', true,
      'account_id', v_account.id,
      'charged_yny', 0,
      'balance_yny', coalesce(v_balance, 0)
    );
  end if;

  select * into v_offer
  from public.yny_menu_offers
  where entity_key = 'neo.profile.acaunt'
    and is_active = true
    and sale_state = 'live';

  if not found then
    return jsonb_build_object('ok', false, 'code', 'offer_not_available');
  end if;

  insert into public.profile_balances(profile_id, balance_yny)
  values (p_profile_id, 0)
  on conflict (profile_id) do nothing;

  select balance_yny into v_balance
  from public.profile_balances
  where profile_id = p_profile_id
  for update;

  if v_balance < v_offer.price_yny then
    return jsonb_build_object(
      'ok', false,
      'code', 'insufficient_balance',
      'price_yny', v_offer.price_yny,
      'balance_yny', v_balance,
      'missing_yny', v_offer.price_yny - v_balance
    );
  end if;

  v_new_balance := v_balance - v_offer.price_yny;

  update public.profile_balances
  set balance_yny = v_new_balance,
      updated_at = now()
  where profile_id = p_profile_id;

  insert into public.balance_transactions (
    id,
    profile_id,
    type,
    amount_yny,
    provider,
    external_transaction_id,
    description
  ) values (
    v_transaction_id,
    p_profile_id,
    'spend',
    v_offer.price_yny,
    'yny_menu',
    'account:' || v_transaction_id::text,
    'Покупка ACCOUNT'
  );

  insert into public.accounts (
    owner_profile_id,
    display_name,
    purchase_transaction_id
  ) values (
    p_profile_id,
    v_clean_name,
    v_transaction_id
  )
  returning * into v_account;

  return jsonb_build_object(
    'ok', true,
    'already_created', false,
    'account_id', v_account.id,
    'transaction_id', v_transaction_id,
    'charged_yny', v_offer.price_yny,
    'balance_yny', v_new_balance
  );
end;
$$;

revoke execute on function public.get_profile_account_quote_v1(uuid) from public, anon, authenticated;
revoke execute on function public.purchase_profile_account_v1(uuid, text) from public, anon, authenticated;
grant execute on function public.get_profile_account_quote_v1(uuid) to service_role;
grant execute on function public.purchase_profile_account_v1(uuid, text) to service_role;

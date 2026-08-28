alter table public.accounts
  alter column purchase_transaction_id drop not null;

alter table public.accounts
  add column if not exists purchase_id uuid,
  add column if not exists purchase_price_yny numeric(24,8),
  add column if not exists purchase_kind text not null default 'system_purchase';

update public.accounts
set purchase_id = coalesce(purchase_id, gen_random_uuid()),
    purchase_price_yny = coalesce(purchase_price_yny, 1),
    purchase_kind = 'system_purchase'
where purchase_id is null
   or purchase_price_yny is null
   or purchase_kind is distinct from 'system_purchase';

alter table public.accounts
  alter column purchase_id set not null,
  alter column purchase_price_yny set not null;

create unique index if not exists accounts_purchase_id_key
  on public.accounts(purchase_id);

alter table public.accounts
  drop constraint if exists accounts_purchase_kind_check;

alter table public.accounts
  add constraint accounts_purchase_kind_check
  check (purchase_kind = 'system_purchase');

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
      'can_purchase', false,
      'purchase_kind', 'system_purchase'
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
    'missing_yny', greatest(v_offer.price_yny - v_balance, 0),
    'purchase_kind', 'system_purchase'
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
  v_purchase_id uuid := gen_random_uuid();
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
      'price_yny', 0,
      'charged_yny', 0,
      'balance_yny', coalesce(v_balance, 0),
      'purchase_kind', 'system_purchase'
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
      'charged_yny', v_offer.price_yny,
      'balance_yny', v_balance,
      'missing_yny', v_offer.price_yny - v_balance,
      'purchase_kind', 'system_purchase'
    );
  end if;

  v_new_balance := v_balance - v_offer.price_yny;

  update public.profile_balances
  set balance_yny = v_new_balance,
      updated_at = now()
  where profile_id = p_profile_id;

  insert into public.accounts (
    owner_profile_id,
    display_name,
    purchase_transaction_id,
    purchase_id,
    purchase_price_yny,
    purchase_kind
  ) values (
    p_profile_id,
    v_clean_name,
    null,
    v_purchase_id,
    v_offer.price_yny,
    'system_purchase'
  )
  returning * into v_account;

  return jsonb_build_object(
    'ok', true,
    'already_created', false,
    'account_id', v_account.id,
    'purchase_id', v_purchase_id,
    'price_yny', v_offer.price_yny,
    'charged_yny', v_offer.price_yny,
    'balance_yny', v_new_balance,
    'purchase_kind', 'system_purchase'
  );
end;
$$;

revoke execute on function public.get_profile_account_quote_v1(uuid) from public, anon, authenticated;
revoke execute on function public.purchase_profile_account_v1(uuid, text) from public, anon, authenticated;
grant execute on function public.get_profile_account_quote_v1(uuid) to service_role;
grant execute on function public.purchase_profile_account_v1(uuid, text) to service_role;

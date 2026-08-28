alter table public.accounts drop constraint if exists accounts_owner_profile_id_key;

alter table public.accounts
  add column if not exists account_form text not null default 'blank',
  add column if not exists purchase_request_id uuid;

alter table public.accounts drop constraint if exists accounts_account_form_check;
alter table public.accounts
  add constraint accounts_account_form_check
  check (account_form = any (array['blank'::text,'group'::text,'page'::text,'assys'::text,'wallet'::text,'cabinet'::text]));

create index if not exists accounts_owner_profile_created_idx
  on public.accounts(owner_profile_id, created_at desc);

create unique index if not exists accounts_owner_purchase_request_uidx
  on public.accounts(owner_profile_id, purchase_request_id)
  where purchase_request_id is not null;

update public.yny_menu_offers
set repeatable = true,
    updated_at = now()
where entity_key = 'neo.profile.acaunt';

create or replace function public.get_profile_accounts_v1(p_profile_id uuid)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_accounts jsonb;
  v_count integer;
begin
  if p_profile_id is null then
    return jsonb_build_object('ok', false, 'code', 'invalid_request');
  end if;

  perform 1 from public.profiles where id = p_profile_id and status = 'active';
  if not found then
    return jsonb_build_object('ok', false, 'code', 'profile_not_found_or_inactive');
  end if;

  select count(*)::integer,
         coalesce(
           jsonb_agg(
             jsonb_build_object(
               'account_id', a.id,
               'display_name', a.display_name,
               'account_form', a.account_form,
               'status', a.status,
               'purchase_id', a.purchase_id,
               'purchase_price_yny', a.purchase_price_yny,
               'created_at', a.created_at,
               'updated_at', a.updated_at
             ) order by a.created_at desc
           ),
           '[]'::jsonb
         )
    into v_count, v_accounts
  from public.accounts a
  where a.owner_profile_id = p_profile_id
    and a.status <> 'archived';

  return jsonb_build_object(
    'ok', true,
    'account_count', coalesce(v_count, 0),
    'accounts', coalesce(v_accounts, '[]'::jsonb)
  );
end;
$$;

create or replace function public.get_profile_account_quote_v1(p_profile_id uuid)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_profile_status text;
  v_balance numeric(24,8) := 0;
  v_count integer := 0;
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
  if not found then v_balance := 0; end if;

  select count(*)::integer into v_count
  from public.accounts
  where owner_profile_id = p_profile_id
    and status <> 'archived';

  return jsonb_build_object(
    'ok', true,
    'entity_key', v_offer.entity_key,
    'display_name', v_offer.display_name,
    'price_yny', v_offer.price_yny,
    'charge_yny', v_offer.price_yny,
    'balance_yny', v_balance,
    'can_purchase', (v_balance >= v_offer.price_yny),
    'missing_yny', greatest(v_offer.price_yny - v_balance, 0),
    'purchase_kind', 'system_purchase',
    'repeatable', true,
    'account_count', v_count
  );
end;
$$;

create or replace function public.purchase_profile_account_v2(
  p_profile_id uuid,
  p_display_name text default null,
  p_request_id uuid default null
)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_balance numeric(24,8) := 0;
  v_new_balance numeric(24,8);
  v_account public.accounts%rowtype;
  v_purchase_id uuid := gen_random_uuid();
  v_clean_name text;
  v_count integer;
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

  if p_request_id is not null then
    select * into v_account
    from public.accounts
    where owner_profile_id = p_profile_id
      and purchase_request_id = p_request_id;

    if found then
      select coalesce(balance_yny, 0) into v_balance
      from public.profile_balances
      where profile_id = p_profile_id;

      select count(*)::integer into v_count
      from public.accounts
      where owner_profile_id = p_profile_id
        and status <> 'archived';

      return jsonb_build_object(
        'ok', true,
        'idempotent_replay', true,
        'account_id', v_account.id,
        'account_form', v_account.account_form,
        'purchase_id', v_account.purchase_id,
        'price_yny', v_account.purchase_price_yny,
        'charged_yny', 0,
        'balance_yny', coalesce(v_balance, 0),
        'purchase_kind', 'system_purchase',
        'account_count', v_count
      );
    end if;
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
    account_form,
    purchase_transaction_id,
    purchase_id,
    purchase_request_id,
    purchase_price_yny,
    purchase_kind
  ) values (
    p_profile_id,
    v_clean_name,
    'blank',
    null,
    v_purchase_id,
    p_request_id,
    v_offer.price_yny,
    'system_purchase'
  )
  returning * into v_account;

  select count(*)::integer into v_count
  from public.accounts
  where owner_profile_id = p_profile_id
    and status <> 'archived';

  return jsonb_build_object(
    'ok', true,
    'idempotent_replay', false,
    'account_id', v_account.id,
    'account_form', v_account.account_form,
    'purchase_id', v_purchase_id,
    'price_yny', v_offer.price_yny,
    'charged_yny', v_offer.price_yny,
    'balance_yny', v_new_balance,
    'purchase_kind', 'system_purchase',
    'account_count', v_count
  );
end;
$$;

revoke all on function public.get_profile_accounts_v1(uuid) from public, anon, authenticated;
revoke all on function public.purchase_profile_account_v2(uuid,text,uuid) from public, anon, authenticated;
grant execute on function public.get_profile_accounts_v1(uuid) to service_role;
grant execute on function public.purchase_profile_account_v2(uuid,text,uuid) to service_role;

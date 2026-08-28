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
  v_tax_yny numeric(24,8);
  v_total_yny numeric(24,8);
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

  v_tax_yny := round(v_offer.price_yny * 0.01, 8);
  v_total_yny := v_offer.price_yny + v_tax_yny;

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
      'neo_tax_rate', 0.01,
      'neo_tax_yny', 0,
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
    'neo_tax_rate', 0.01,
    'neo_tax_yny', v_tax_yny,
    'charge_yny', v_total_yny,
    'balance_yny', v_balance,
    'can_purchase', (v_balance >= v_total_yny),
    'missing_yny', greatest(v_total_yny - v_balance, 0)
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
  v_price_transaction_id uuid := gen_random_uuid();
  v_tax_transaction_id uuid := gen_random_uuid();
  v_tax_yny numeric(24,8);
  v_total_yny numeric(24,8);
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
      'neo_tax_rate', 0.01,
      'neo_tax_yny', 0,
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

  v_tax_yny := round(v_offer.price_yny * 0.01, 8);
  v_total_yny := v_offer.price_yny + v_tax_yny;

  insert into public.profile_balances(profile_id, balance_yny)
  values (p_profile_id, 0)
  on conflict (profile_id) do nothing;

  select balance_yny into v_balance
  from public.profile_balances
  where profile_id = p_profile_id
  for update;

  if v_balance < v_total_yny then
    return jsonb_build_object(
      'ok', false,
      'code', 'insufficient_balance',
      'price_yny', v_offer.price_yny,
      'neo_tax_rate', 0.01,
      'neo_tax_yny', v_tax_yny,
      'charged_yny', v_total_yny,
      'balance_yny', v_balance,
      'missing_yny', v_total_yny - v_balance
    );
  end if;

  v_new_balance := v_balance - v_total_yny;

  update public.profile_balances
  set balance_yny = v_new_balance,
      updated_at = now()
  where profile_id = p_profile_id;

  insert into public.balance_transactions (
    id, profile_id, type, amount_yny, provider, external_transaction_id, description
  ) values (
    v_price_transaction_id, p_profile_id, 'spend', v_offer.price_yny, 'yny_menu',
    'account:' || v_purchase_id::text || ':price', 'Покупка ACCOUNT'
  );

  insert into public.balance_transactions (
    id, profile_id, type, amount_yny, provider, external_transaction_id, description
  ) values (
    v_tax_transaction_id, p_profile_id, 'spend', v_tax_yny, 'neo_world_tax',
    'account:' || v_purchase_id::text || ':neo_tax', 'Налог Нео Мира 1% — покупка ACCOUNT'
  );

  insert into public.accounts (
    owner_profile_id, display_name, purchase_transaction_id
  ) values (
    p_profile_id, v_clean_name, v_price_transaction_id
  )
  returning * into v_account;

  return jsonb_build_object(
    'ok', true,
    'already_created', false,
    'account_id', v_account.id,
    'purchase_id', v_purchase_id,
    'price_transaction_id', v_price_transaction_id,
    'tax_transaction_id', v_tax_transaction_id,
    'price_yny', v_offer.price_yny,
    'neo_tax_rate', 0.01,
    'neo_tax_yny', v_tax_yny,
    'charged_yny', v_total_yny,
    'balance_yny', v_new_balance
  );
end;
$$;

revoke execute on function public.get_profile_account_quote_v1(uuid) from public, anon, authenticated;
revoke execute on function public.purchase_profile_account_v1(uuid, text) from public, anon, authenticated;
grant execute on function public.get_profile_account_quote_v1(uuid) to service_role;
grant execute on function public.purchase_profile_account_v1(uuid, text) to service_role;

create or replace function public.get_profile_account_quote_v1(p_profile_id uuid)
returns jsonb
language plpgsql
set search_path = ''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_profile_status text;
  v_balance numeric(24,8) := 0;
  v_accounts jsonb := '[]'::jsonb;
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
    'entity_key', v_offer.entity_key,
    'display_name', v_offer.display_name,
    'price_yny', v_offer.price_yny,
    'charge_yny', v_offer.price_yny,
    'balance_yny', v_balance,
    'can_purchase', (v_balance >= v_offer.price_yny),
    'missing_yny', greatest(v_offer.price_yny - v_balance, 0),
    'purchase_kind', 'system_purchase',
    'repeatable', true,
    'account_count', coalesce(v_count, 0),
    'accounts', coalesce(v_accounts, '[]'::jsonb)
  );
end;
$$;

create or replace function public.purchase_profile_account_v1(
  p_profile_id uuid,
  p_display_name text default null
)
returns jsonb
language sql
set search_path = ''
as $$
  select public.purchase_profile_account_v2(
    p_profile_id,
    p_display_name,
    gen_random_uuid()
  );
$$;

revoke all on function public.purchase_profile_account_v1(uuid,text) from public, anon, authenticated;
grant execute on function public.purchase_profile_account_v1(uuid,text) to service_role;

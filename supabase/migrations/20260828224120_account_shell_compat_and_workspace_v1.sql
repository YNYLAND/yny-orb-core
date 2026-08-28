-- Compatibility/list/workspace functions after removing account_form.

create or replace function public.get_profile_accounts_v1(p_profile_id uuid)
returns jsonb language plpgsql set search_path='' as $$
declare v_accounts jsonb; v_count integer;
begin
 if p_profile_id is null then return jsonb_build_object('ok',false,'code','invalid_request'); end if;
 perform 1 from public.profiles where id=p_profile_id and status='active';
 if not found then return jsonb_build_object('ok',false,'code','profile_not_found_or_inactive'); end if;
 select count(*)::int,
        coalesce(jsonb_agg(jsonb_build_object(
          'account_id',a.id,'display_name',a.display_name,'avatar_url',a.avatar_url,
          'setup_state',a.setup_state,'status',a.status,'list_position',a.list_position,
          'purchase_id',a.purchase_id,'purchase_price_yny',a.purchase_price_yny,
          'created_at',a.created_at,'updated_at',a.updated_at
        ) order by a.list_position asc nulls last,a.created_at asc),'[]'::jsonb)
 into v_count,v_accounts
 from public.accounts a where a.owner_profile_id=p_profile_id and a.status<>'archived';
 return jsonb_build_object('ok',true,'account_count',coalesce(v_count,0),'accounts',coalesce(v_accounts,'[]'::jsonb));
end $$;

create or replace function public.get_profile_account_quote_v1(p_profile_id uuid)
returns jsonb language plpgsql set search_path='' as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_status text;
  v_balance numeric(24,8):=0;
  v_accounts jsonb:='[]'::jsonb;
  v_count int:=0;
begin
 if p_profile_id is null then return jsonb_build_object('ok',false,'code','invalid_request'); end if;
 select status into v_status from public.profiles where id=p_profile_id;
 if not found then return jsonb_build_object('ok',false,'code','profile_not_found'); end if;
 if v_status<>'active' then return jsonb_build_object('ok',false,'code','profile_not_active'); end if;
 select * into v_offer from public.yny_menu_offers where entity_key='neo.profile.acaunt' and is_active=true and sale_state='live';
 if not found then return jsonb_build_object('ok',false,'code','offer_not_available'); end if;
 select coalesce(balance_yny,0) into v_balance from public.profile_balances where profile_id=p_profile_id;
 if not found then v_balance:=0; end if;
 select count(*)::int,
        coalesce(jsonb_agg(jsonb_build_object(
          'account_id',a.id,'display_name',a.display_name,'avatar_url',a.avatar_url,
          'setup_state',a.setup_state,'status',a.status,'list_position',a.list_position,
          'purchase_id',a.purchase_id,'purchase_price_yny',a.purchase_price_yny,
          'created_at',a.created_at,'updated_at',a.updated_at
        ) order by a.list_position asc nulls last,a.created_at asc),'[]'::jsonb)
 into v_count,v_accounts
 from public.accounts a where a.owner_profile_id=p_profile_id and a.status<>'archived';
 return jsonb_build_object(
   'ok',true,
   'entity_key',v_offer.entity_key,
   'display_name',v_offer.display_name,
   'price_yny',v_offer.price_yny,
   'charge_yny',v_offer.price_yny,
   'balance_yny',v_balance,
   'can_purchase',(v_balance>=v_offer.price_yny),
   'missing_yny',greatest(v_offer.price_yny-v_balance,0),
   'purchase_kind','system_purchase',
   'repeatable',true,
   'account_count',coalesce(v_count,0),
   'accounts',coalesce(v_accounts,'[]'::jsonb)
 );
end $$;

create or replace function public.purchase_profile_account_v2(
  p_profile_id uuid,
  p_display_name text default null,
  p_request_id uuid default null
) returns jsonb
language sql
set search_path=''
as $$
  select public.purchase_profile_account_repeatable_v1(p_profile_id,null,p_request_id);
$$;

create or replace function public.get_account_workspace_v1(p_profile_id uuid,p_account_id uuid)
returns jsonb language plpgsql set search_path='' as $$
declare
  v_account public.accounts%rowtype;
  v_modules jsonb;
begin
 select * into v_account
 from public.accounts
 where id=p_account_id and owner_profile_id=p_profile_id and status<>'archived';
 if not found then return jsonb_build_object('ok',false,'code','account_not_found'); end if;

 select coalesce(jsonb_agg(jsonb_build_object(
   'module_id',m.id,
   'module_key',m.module_key,
   'display_name',c.display_name,
   'package_kind',c.package_kind,
   'status',m.status,
   'sort_order',m.sort_order,
   'config',m.config,
   'installed_at',m.installed_at,
   'components',coalesce((
     select jsonb_agg(jsonb_build_object(
       'component_key',x.component_key,
       'display_name',x.display_name,
       'status',x.status,
       'sort_order',x.sort_order,
       'config',x.config
     ) order by x.sort_order)
     from public.account_module_components x
     where x.account_module_id=m.id and x.status<>'archived'
   ),'[]'::jsonb)
 ) order by m.sort_order,m.installed_at),'[]'::jsonb)
 into v_modules
 from public.account_modules m
 join public.account_module_catalog c on c.module_key=m.module_key
 where m.account_id=p_account_id and m.status<>'archived';

 return jsonb_build_object(
   'ok',true,
   'account',jsonb_build_object(
     'account_id',v_account.id,
     'display_name',v_account.display_name,
     'avatar_url',v_account.avatar_url,
     'setup_state',v_account.setup_state,
     'list_position',v_account.list_position
   ),
   'modules',coalesce(v_modules,'[]'::jsonb)
 );
end $$;

revoke all on function public.get_account_workspace_v1(uuid,uuid) from public,anon,authenticated;
grant execute on function public.get_account_workspace_v1(uuid,uuid) to service_role;

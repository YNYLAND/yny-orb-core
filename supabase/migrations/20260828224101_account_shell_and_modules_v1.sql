-- ACCOUNT remains a stable shell; PAGE/GROUP/etc are installed inside it as modules.

alter table public.accounts drop constraint if exists accounts_account_form_check;
alter table public.accounts drop column if exists account_form;
alter table public.accounts add column if not exists setup_state text not null default 'blank';
alter table public.accounts add column if not exists avatar_url text;
alter table public.accounts add column if not exists list_position bigint;
alter table public.accounts add column if not exists configured_at timestamptz;
alter table public.accounts add constraint accounts_setup_state_check check (setup_state in ('blank','ready'));

update public.accounts
set setup_state = case when nullif(btrim(coalesce(display_name,'')),'') is null then 'blank' else 'ready' end,
    configured_at = case when nullif(btrim(coalesce(display_name,'')),'') is null then null else coalesce(configured_at, updated_at, created_at) end;

with ranked as (
  select id, row_number() over (partition by owner_profile_id order by created_at asc, id asc) as rn
  from public.accounts
)
update public.accounts a
set list_position = r.rn
from ranked r
where r.id = a.id and a.list_position is null;

create index if not exists accounts_owner_list_position_idx
  on public.accounts(owner_profile_id, list_position, created_at);

create table if not exists public.account_module_catalog (
  module_key text primary key,
  display_name text not null,
  package_kind text not null default 'module' check (package_kind in ('module','bundle')),
  unpack_manifest jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.account_modules (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts(id) on delete cascade,
  module_key text not null references public.account_module_catalog(module_key) on delete restrict,
  status text not null default 'active' check (status in ('active','disabled','archived')),
  sort_order integer not null default 100,
  config jsonb not null default '{}'::jsonb,
  installed_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(account_id,module_key)
);

create table if not exists public.account_module_components (
  id uuid primary key default gen_random_uuid(),
  account_module_id uuid not null references public.account_modules(id) on delete cascade,
  component_key text not null,
  display_name text not null,
  status text not null default 'active' check (status in ('active','disabled','archived')),
  sort_order integer not null default 100,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(account_module_id,component_key)
);

insert into public.account_module_catalog(module_key,display_name,package_kind,unpack_manifest,sort_order)
values
 ('neo.acaunt.page','PAGE','module','[]'::jsonb,10),
 ('neo.acaunt.grup','GROUP','bundle','[{"key":"topics","name":"TOPICS","sort_order":10},{"key":"rooms","name":"ROOMS","sort_order":20},{"key":"chats","name":"CHATS","sort_order":30},{"key":"feed","name":"FEED","sort_order":40},{"key":"orb","name":"ORB","sort_order":50}]'::jsonb,20),
 ('neo.acaunt.assys','ASSYS','module','[]'::jsonb,30),
 ('neo.acaunt.wallet','WALLET','module','[]'::jsonb,40),
 ('neo.acaunt.cabinet','CABINET','module','[]'::jsonb,50)
on conflict (module_key) do update set
 display_name=excluded.display_name,
 package_kind=excluded.package_kind,
 unpack_manifest=excluded.unpack_manifest,
 sort_order=excluded.sort_order,
 updated_at=now();

alter table public.account_module_catalog enable row level security;
alter table public.account_modules enable row level security;
alter table public.account_module_components enable row level security;
revoke all on public.account_module_catalog, public.account_modules, public.account_module_components from anon, authenticated;
grant select,insert,update,delete on public.account_module_catalog, public.account_modules, public.account_module_components to service_role;

create or replace function public.configure_profile_account_v1(
  p_profile_id uuid,
  p_account_id uuid,
  p_display_name text,
  p_avatar_url text default null
) returns jsonb
language plpgsql
set search_path=''
as $$
declare
  v_name text := nullif(btrim(coalesce(p_display_name,'')), '');
  v_account public.accounts%rowtype;
begin
  if p_profile_id is null or p_account_id is null then
    return jsonb_build_object('ok',false,'code','invalid_request');
  end if;
  if v_name is null then
    return jsonb_build_object('ok',false,'code','display_name_required');
  end if;
  if length(v_name) > 100 then
    return jsonb_build_object('ok',false,'code','display_name_too_long');
  end if;

  update public.accounts
  set display_name=v_name,
      avatar_url=nullif(btrim(coalesce(p_avatar_url,'')),''),
      setup_state='ready',
      configured_at=coalesce(configured_at,now()),
      updated_at=now()
  where id=p_account_id and owner_profile_id=p_profile_id and status='active'
  returning * into v_account;

  if not found then return jsonb_build_object('ok',false,'code','account_not_found'); end if;

  return jsonb_build_object(
    'ok',true,
    'account_id',v_account.id,
    'display_name',v_account.display_name,
    'avatar_url',v_account.avatar_url,
    'setup_state',v_account.setup_state,
    'list_position',v_account.list_position
  );
end;
$$;

create or replace function public.install_account_module_v1(
  p_profile_id uuid,
  p_account_id uuid,
  p_module_key text
) returns jsonb
language plpgsql
set search_path=''
as $$
declare
  v_catalog public.account_module_catalog%rowtype;
  v_module public.account_modules%rowtype;
  v_item jsonb;
begin
  perform 1
  from public.accounts
  where id=p_account_id and owner_profile_id=p_profile_id and status='active' and setup_state='ready'
  for update;
  if not found then return jsonb_build_object('ok',false,'code','account_not_ready'); end if;

  select * into v_catalog
  from public.account_module_catalog
  where module_key=p_module_key and is_active=true;
  if not found then return jsonb_build_object('ok',false,'code','module_not_available'); end if;

  insert into public.account_modules(account_id,module_key,sort_order)
  values(p_account_id,v_catalog.module_key,v_catalog.sort_order)
  on conflict(account_id,module_key) do update set status='active', updated_at=now()
  returning * into v_module;

  if v_catalog.package_kind='bundle' then
    for v_item in select value from jsonb_array_elements(v_catalog.unpack_manifest)
    loop
      insert into public.account_module_components(account_module_id,component_key,display_name,sort_order)
      values(v_module.id,v_item->>'key',v_item->>'name',coalesce((v_item->>'sort_order')::int,100))
      on conflict(account_module_id,component_key) do update set
        status='active',
        display_name=excluded.display_name,
        sort_order=excluded.sort_order,
        updated_at=now();
    end loop;
  end if;

  return jsonb_build_object(
    'ok',true,
    'account_id',p_account_id,
    'module_id',v_module.id,
    'module_key',v_module.module_key,
    'package_kind',v_catalog.package_kind,
    'unpacked',v_catalog.unpack_manifest
  );
end;
$$;

create or replace function public.reorder_profile_account_v1(
  p_profile_id uuid,
  p_account_id uuid,
  p_list_position bigint
) returns jsonb
language plpgsql
set search_path=''
as $$
begin
  if p_list_position is null or p_list_position < 1 then
    return jsonb_build_object('ok',false,'code','position_invalid');
  end if;

  update public.accounts
  set list_position=p_list_position, updated_at=now()
  where id=p_account_id and owner_profile_id=p_profile_id;

  if not found then return jsonb_build_object('ok',false,'code','account_not_found'); end if;
  return jsonb_build_object('ok',true,'account_id',p_account_id,'list_position',p_list_position);
end;
$$;

revoke all on function public.configure_profile_account_v1(uuid,uuid,text,text) from public,anon,authenticated;
revoke all on function public.install_account_module_v1(uuid,uuid,text) from public,anon,authenticated;
revoke all on function public.reorder_profile_account_v1(uuid,uuid,bigint) from public,anon,authenticated;
grant execute on function public.configure_profile_account_v1(uuid,uuid,text,text) to service_role;
grant execute on function public.install_account_module_v1(uuid,uuid,text) to service_role;
grant execute on function public.reorder_profile_account_v1(uuid,uuid,bigint) to service_role;

create or replace function public.purchase_profile_account_repeatable_v1(
  p_profile_id uuid,
  p_display_name text default null,
  p_request_id uuid default null
) returns jsonb
language plpgsql
set search_path=''
as $$
declare
  v_offer public.yny_menu_offers%rowtype;
  v_balance numeric(24,8):=0;
  v_new_balance numeric(24,8);
  v_account public.accounts%rowtype;
  v_purchase_id uuid:=gen_random_uuid();
  v_next_position bigint;
begin
  if p_profile_id is null then return jsonb_build_object('ok',false,'code','invalid_request'); end if;

  perform 1 from public.profiles where id=p_profile_id and status='active' for update;
  if not found then return jsonb_build_object('ok',false,'code','profile_not_found_or_inactive'); end if;

  if p_request_id is not null then
    select * into v_account
    from public.accounts
    where owner_profile_id=p_profile_id and purchase_request_id=p_request_id;
    if found then
      select coalesce(balance_yny,0) into v_balance
      from public.profile_balances
      where profile_id=p_profile_id;
      return jsonb_build_object(
        'ok',true,
        'replayed',true,
        'account_id',v_account.id,
        'purchase_id',v_account.purchase_id,
        'charged_yny',0,
        'balance_yny',coalesce(v_balance,0),
        'setup_state',v_account.setup_state
      );
    end if;
  end if;

  select * into v_offer
  from public.yny_menu_offers
  where entity_key='neo.profile.acaunt' and is_active=true and sale_state='live';
  if not found then return jsonb_build_object('ok',false,'code','offer_not_available'); end if;

  insert into public.profile_balances(profile_id,balance_yny)
  values(p_profile_id,0)
  on conflict(profile_id) do nothing;

  select balance_yny into v_balance
  from public.profile_balances
  where profile_id=p_profile_id
  for update;

  if v_balance < v_offer.price_yny then
    return jsonb_build_object(
      'ok',false,
      'code','insufficient_balance',
      'price_yny',v_offer.price_yny,
      'balance_yny',v_balance,
      'missing_yny',v_offer.price_yny-v_balance,
      'purchase_kind','system_purchase'
    );
  end if;

  v_new_balance:=v_balance-v_offer.price_yny;
  update public.profile_balances set balance_yny=v_new_balance,updated_at=now() where profile_id=p_profile_id;
  select coalesce(max(list_position),0)+1 into v_next_position from public.accounts where owner_profile_id=p_profile_id;

  insert into public.accounts(
    owner_profile_id,display_name,purchase_transaction_id,purchase_id,
    purchase_price_yny,purchase_kind,purchase_request_id,setup_state,list_position
  ) values (
    p_profile_id,null,null,v_purchase_id,v_offer.price_yny,'system_purchase',p_request_id,'blank',v_next_position
  ) returning * into v_account;

  return jsonb_build_object(
    'ok',true,
    'replayed',false,
    'account_id',v_account.id,
    'purchase_id',v_purchase_id,
    'price_yny',v_offer.price_yny,
    'charged_yny',v_offer.price_yny,
    'balance_yny',v_new_balance,
    'purchase_kind','system_purchase',
    'setup_state','blank',
    'list_position',v_next_position
  );
end;
$$;

revoke all on function public.purchase_profile_account_repeatable_v1(uuid,text,uuid) from public,anon,authenticated;
grant execute on function public.purchase_profile_account_repeatable_v1(uuid,text,uuid) to service_role;

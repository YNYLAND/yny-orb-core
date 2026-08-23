-- ORB CORE DEV baseline
-- Mirrors the clean structural baseline created in Supabase project YNY DEV.
-- This migration is intended for isolated DEV/bootstrap environments.

create extension if not exists pgcrypto;
create extension if not exists vector;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  profile_number text unique not null,
  profile_type text not null,
  status text not null,
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.orb_modes (
  mode_key text primary key,
  display_name text not null,
  description text,
  panel_kind text not null check (panel_kind in ('settings','catalog')),
  requires_purchase boolean not null default false,
  root_skill_key text,
  sort_order integer not null default 100,
  is_active boolean not null default true,
  purpose text,
  frame text,
  success_metric text,
  retrieval_policy jsonb not null default '{}'::jsonb,
  capability_policy jsonb not null default '{}'::jsonb,
  agent_policy jsonb not null default '{}'::jsonb,
  offer_policy jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

insert into public.orb_modes(mode_key, display_name, panel_kind, requires_purchase, sort_order, is_active)
values
  ('system','SYSTEM','settings',false,10,true),
  ('ynychat','YNY CHAT','catalog',true,20,true),
  ('corp','CORP','catalog',true,30,true)
on conflict (mode_key) do nothing;

create table if not exists public.skill_catalog (
  skill_key text primary key check (skill_key ~ '^[a-z0-9_]+$'),
  display_name text not null,
  description text,
  price_yny numeric not null default 0 check (price_yny >= 0),
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  mode_key text references public.orb_modes(mode_key),
  sale_state text not null default 'live' check (sale_state in ('live','planned'))
);

create table if not exists public.skill_dependencies (
  skill_key text not null references public.skill_catalog(skill_key) on delete cascade,
  required_skill_key text not null references public.skill_catalog(skill_key) on delete restrict,
  created_at timestamptz not null default now(),
  primary key (skill_key, required_skill_key)
);

create table if not exists public.profile_skills (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  skill_key text not null references public.skill_catalog(skill_key) on delete restrict,
  created_at timestamptz not null default now()
);

create table if not exists public.conversation_messages (
  id uuid primary key default gen_random_uuid(),
  session_id text,
  role text,
  message text,
  created_at timestamptz default now(),
  mode text not null default 'system'
);

create table if not exists public.session_summary_blocks (
  id uuid primary key default gen_random_uuid(),
  session_id text not null,
  block_index bigint not null,
  message_from bigint,
  message_to bigint,
  summary text,
  created_at timestamp not null default now(),
  title text,
  tags text[],
  mode text,
  embedding vector(1536)
);

create table if not exists public.context_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  title text not null,
  goal text,
  context text,
  status text not null default 'active' check (status in ('active','paused','blocked','completed','cancelled','reframed')),
  current_state jsonb not null default '{}'::jsonb,
  target_state jsonb not null default '{}'::jsonb,
  parent_session_id uuid references public.context_sessions(id) on delete set null,
  linked_entities jsonb not null default '[]'::jsonb,
  result jsonb,
  result_type text,
  closure_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  closed_at timestamptz
);

create table if not exists public.session_checks (
  id uuid primary key default gen_random_uuid(),
  context_session_id uuid not null references public.context_sessions(id) on delete cascade,
  title text not null,
  description text,
  status text not null default 'potential' check (status in ('potential','actionable','blocked','completed','cancelled')),
  required boolean not null default false,
  result jsonb,
  capability_keys text[] not null default '{}',
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.memory_events (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete set null,
  session_id text,
  context_session_id uuid references public.context_sessions(id) on delete set null,
  source_message_id uuid,
  mode text default 'system',
  title text,
  summary text not null,
  memory_type text,
  event_type text,
  importance text default 'normal',
  tags text[],
  raw_event jsonb,
  state_delta jsonb,
  result jsonb,
  confidence numeric default 0.8,
  created_at timestamptz not null default now()
);

create table if not exists public.profile_memory (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid references public.profiles(id) on delete cascade,
  memory_type text not null,
  title text,
  content text not null,
  importance text default 'normal',
  confidence numeric default 0.8,
  epistemic_status text not null default 'observed' check (epistemic_status in ('observed','confirmed','inferred')),
  tags text[],
  source_type text,
  source_id uuid,
  source_session_id text,
  embedding vector(1536),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orb_capabilities (
  capability_key text primary key check (capability_key ~ '^[A-Z0-9_]+$'),
  display_name text not null,
  description text,
  parent_capability_key text references public.orb_capabilities(capability_key) on delete set null,
  system_status text not null default 'concept' check (system_status in ('concept','planned','implemented','available','deprecated')),
  category text,
  produces text[] not null default '{}',
  can_close text[] not null default '{}',
  requires_modes text[] not null default '{}',
  requires_skills text[] not null default '{}',
  requires_connectors text[] not null default '{}',
  activation_type text not null default 'core',
  activation_price_yny numeric,
  usage_billing jsonb not null default '{}'::jsonb,
  entity_page text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orb_capability_mode_profiles (
  capability_key text not null references public.orb_capabilities(capability_key) on delete cascade,
  mode_key text not null references public.orb_modes(mode_key) on delete cascade,
  execution_profile text not null,
  is_available boolean not null default true,
  provider_strategy text,
  multi_agent boolean not null default false,
  config jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (capability_key, mode_key)
);

create index if not exists context_sessions_profile_status_idx on public.context_sessions(profile_id, status, updated_at desc);
create index if not exists session_checks_session_status_idx on public.session_checks(context_session_id, status, sort_order);
create index if not exists session_checks_capability_keys_gin_idx on public.session_checks using gin(capability_keys);
create index if not exists memory_events_context_session_idx on public.memory_events(context_session_id, created_at desc);

alter table public.profiles enable row level security;
alter table public.orb_modes enable row level security;
alter table public.skill_catalog enable row level security;
alter table public.skill_dependencies enable row level security;
alter table public.profile_skills enable row level security;
alter table public.conversation_messages enable row level security;
alter table public.session_summary_blocks enable row level security;
alter table public.context_sessions enable row level security;
alter table public.session_checks enable row level security;
alter table public.memory_events enable row level security;
alter table public.profile_memory enable row level security;
alter table public.orb_capabilities enable row level security;
alter table public.orb_capability_mode_profiles enable row level security;

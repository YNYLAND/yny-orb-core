-- ORB MEMORY CORE v0.1.0
-- Additive Supabase/Postgres draft.
-- IMPORTANT: session_summary_blocks remain raw-discourse summaries.
-- They are intentionally NOT bound to context_sessions in this migration.

create extension if not exists pgcrypto;

create table if not exists public.context_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid null,
  parent_session_id uuid null references public.context_sessions(id) on delete set null,
  title text not null,
  goal text null,
  context text null,
  current_state text null,
  target_state text null,
  status text not null default 'active'
    check (status in ('active','paused','blocked','completed','cancelled','reframed','merged','closed')),
  result_summary text null,
  result jsonb not null default '{}'::jsonb,
  closure_reason text null,
  opened_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  closed_at timestamptz null
);

create index if not exists context_sessions_profile_status_idx
  on public.context_sessions(profile_id, status, updated_at desc);

create index if not exists context_sessions_parent_idx
  on public.context_sessions(parent_session_id);

create table if not exists public.session_checks (
  id uuid primary key default gen_random_uuid(),
  context_session_id uuid not null references public.context_sessions(id) on delete cascade,
  label text not null,
  description text null,
  outcome_key text null,
  status text not null default 'open'
    check (status in ('open','potential','actionable','in_progress','completed','skipped','cancelled','blocked')),
  required boolean not null default false,
  position integer not null default 0,
  capability_keys text[] not null default '{}',
  result_summary text null,
  result jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz null
);

create index if not exists session_checks_session_status_idx
  on public.session_checks(context_session_id, status, position);

create index if not exists session_checks_capabilities_gin_idx
  on public.session_checks using gin(capability_keys);

alter table public.memory_events
  add column if not exists context_session_id uuid null;

create index if not exists memory_events_context_session_idx
  on public.memory_events(context_session_id, created_at desc);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'memory_events_context_session_id_fkey'
  ) then
    alter table public.memory_events
      add constraint memory_events_context_session_id_fkey
      foreign key (context_session_id)
      references public.context_sessions(id)
      on delete set null;
  end if;
end $$;

alter table public.memory_events
  add column if not exists event_type text null,
  add column if not exists state_delta jsonb not null default '{}'::jsonb,
  add column if not exists result jsonb not null default '{}'::jsonb,
  add column if not exists confidence numeric(4,3) null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'memory_events_confidence_range'
  ) then
    alter table public.memory_events
      add constraint memory_events_confidence_range
      check (confidence is null or (confidence >= 0 and confidence <= 1));
  end if;
end $$;

create or replace view public.actor_achievements as
select
  id as context_session_id,
  profile_id,
  title,
  goal,
  result_summary,
  result,
  status,
  opened_at,
  closed_at
from public.context_sessions
where status in ('completed','closed')
  and (result_summary is not null or result <> '{}'::jsonb);

create or replace function public.set_orb_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists context_sessions_set_updated_at on public.context_sessions;
create trigger context_sessions_set_updated_at
before update on public.context_sessions
for each row execute function public.set_orb_updated_at();

drop trigger if exists session_checks_set_updated_at on public.session_checks;
create trigger session_checks_set_updated_at
before update on public.session_checks
for each row execute function public.set_orb_updated_at();

-- NOT INCLUDED IN v0.1:
-- - changes to session_summary_blocks: summaries continue to be generated from raw conversation_messages;
-- - monthly profile chronicle snapshots;
-- - Guide Core runtime logic;
-- - RLS policies (must be aligned with the project's existing auth/profile policy before deployment).

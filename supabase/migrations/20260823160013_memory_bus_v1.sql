alter table public.memory_events
  add column if not exists durable_memory_processed_at timestamptz,
  add column if not exists durable_memory_count integer not null default 0,
  add column if not exists durable_memory_last_error text;

create index if not exists memory_events_durable_pending_idx
  on public.memory_events(profile_id, created_at)
  where durable_memory_processed_at is null and profile_id is not null;

create or replace function public.mirror_memory_event_to_profile_memory()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.profile_id is null or nullif(btrim(coalesce(new.summary, '')), '') is null then
    return new;
  end if;

  if not exists (
    select 1
    from public.profile_memory pm
    where pm.source_id = new.id
      and pm.source_type in ('memory_event_direct', 'memory_event')
  ) then
    insert into public.profile_memory (
      profile_id,
      memory_type,
      title,
      content,
      importance,
      confidence,
      tags,
      source_type,
      source_id,
      source_session_id,
      is_active
    ) values (
      new.profile_id,
      coalesce(new.memory_type, 'context'),
      new.title,
      new.summary,
      coalesce(new.importance, 'normal'),
      0.85,
      coalesce(new.tags, array[]::text[]),
      'memory_event_direct',
      new.id,
      new.session_id,
      true
    );
  end if;

  return new;
end;
$$;

revoke all on function public.mirror_memory_event_to_profile_memory() from public, anon, authenticated;

drop trigger if exists memory_events_profile_memory_mirror on public.memory_events;
create trigger memory_events_profile_memory_mirror
after insert on public.memory_events
for each row
execute function public.mirror_memory_event_to_profile_memory();

insert into public.profile_memory (
  profile_id,
  memory_type,
  title,
  content,
  importance,
  confidence,
  tags,
  source_type,
  source_id,
  source_session_id,
  is_active
)
select
  me.profile_id,
  coalesce(me.memory_type, 'context'),
  me.title,
  me.summary,
  coalesce(me.importance, 'normal'),
  0.85,
  coalesce(me.tags, array[]::text[]),
  'memory_event_direct',
  me.id,
  me.session_id,
  true
from public.memory_events me
where me.profile_id is not null
  and nullif(btrim(coalesce(me.summary, '')), '') is not null
  and not exists (
    select 1
    from public.profile_memory pm
    where pm.source_id = me.id
      and pm.source_type in ('memory_event_direct', 'memory_event')
  );

create or replace function public.verify_orb_memory_secret(p_secret text)
returns boolean
language sql
stable
security definer
set search_path = public, vault
as $$
  select exists (
    select 1
    from vault.decrypted_secrets s
    where s.name = 'orb_memory_internal_secret'
      and s.decrypted_secret = p_secret
  );
$$;

revoke all on function public.verify_orb_memory_secret(text) from public, anon, authenticated;
grant execute on function public.verify_orb_memory_secret(text) to service_role;

-- Summary embeddings are now created directly by memory-summary-builder.
-- The previous HTTP trigger did not have working authentication.
drop trigger if exists session_summary_blocks_embed on public.session_summary_blocks;

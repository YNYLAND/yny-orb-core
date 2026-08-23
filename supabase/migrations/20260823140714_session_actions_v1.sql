-- ORB semantic session actions v1
-- Closed check = achieved result, never a bare to-do toggle.

create or replace function public.orb_open_context_session_v1(
  p_profile_id uuid,
  p_title text,
  p_goal text default null,
  p_context text default null,
  p_checks jsonb default '[]'::jsonb
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_session_id uuid;
  v_check jsonb;
begin
  if nullif(trim(p_title), '') is null then
    raise exception 'Session title is required';
  end if;

  insert into public.context_sessions(profile_id, title, goal, context, status)
  values (p_profile_id, trim(p_title), nullif(trim(coalesce(p_goal,'')),''), nullif(trim(coalesce(p_context,'')),''), 'active')
  returning id into v_session_id;

  if jsonb_typeof(coalesce(p_checks,'[]'::jsonb)) = 'array' then
    for v_check in select value from jsonb_array_elements(coalesce(p_checks,'[]'::jsonb))
    loop
      if nullif(trim(coalesce(v_check->>'title','')), '') is not null then
        insert into public.session_checks(
          context_session_id,
          title,
          description,
          status,
          required,
          capability_keys,
          sort_order
        ) values (
          v_session_id,
          trim(v_check->>'title'),
          nullif(trim(coalesce(v_check->>'description','')),''),
          coalesce(nullif(v_check->>'status',''),'potential'),
          coalesce((v_check->>'required')::boolean,false),
          coalesce(array(select jsonb_array_elements_text(coalesce(v_check->'capability_keys','[]'::jsonb))), '{}'::text[]),
          coalesce((v_check->>'sort_order')::integer,100)
        );
      end if;
    end loop;
  end if;

  insert into public.memory_events(
    profile_id, context_session_id, mode, title, summary, memory_type, event_type, importance, confidence
  ) values (
    p_profile_id, v_session_id, 'system', trim(p_title),
    coalesce(nullif(trim(coalesce(p_goal,'')),''), 'Открыта смысловая сессия: ' || trim(p_title)),
    'context', 'session_opened', 'normal', 1.0
  );

  return jsonb_build_object(
    'ok', true,
    'context_session_id', v_session_id,
    'status', 'active'
  );
end;
$$;

create or replace function public.orb_complete_check_v1(
  p_check_id uuid,
  p_result jsonb,
  p_summary text
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_check public.session_checks%rowtype;
  v_session public.context_sessions%rowtype;
begin
  if nullif(trim(coalesce(p_summary,'')), '') is null then
    raise exception 'A completed check requires a result summary';
  end if;

  select * into v_check
  from public.session_checks
  where id = p_check_id
  for update;

  if not found then
    raise exception 'Check not found';
  end if;

  select * into v_session
  from public.context_sessions
  where id = v_check.context_session_id;

  if v_session.status in ('completed','cancelled') then
    raise exception 'Session is already closed';
  end if;

  update public.session_checks
  set
    status = 'completed',
    result = coalesce(p_result, '{}'::jsonb),
    completed_at = now(),
    updated_at = now()
  where id = p_check_id
  returning * into v_check;

  insert into public.memory_events(
    profile_id, context_session_id, mode, title, summary, memory_type, event_type, importance, result, confidence
  ) values (
    v_session.profile_id,
    v_session.id,
    'system',
    v_check.title,
    trim(p_summary),
    'result',
    'action_completed',
    'normal',
    coalesce(p_result, '{}'::jsonb),
    1.0
  );

  return jsonb_build_object(
    'ok', true,
    'check_id', v_check.id,
    'context_session_id', v_session.id,
    'status', v_check.status,
    'result', v_check.result
  );
end;
$$;

create or replace function public.orb_complete_session_v1(
  p_context_session_id uuid,
  p_result jsonb,
  p_result_type text,
  p_summary text,
  p_closure_reason text default 'goal_achieved'
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_session public.context_sessions%rowtype;
  v_open_required integer;
begin
  if nullif(trim(coalesce(p_summary,'')), '') is null then
    raise exception 'A completed session requires a result summary';
  end if;

  select * into v_session
  from public.context_sessions
  where id = p_context_session_id
  for update;

  if not found then
    raise exception 'Context session not found';
  end if;

  select count(*) into v_open_required
  from public.session_checks
  where context_session_id = p_context_session_id
    and required = true
    and status <> 'completed';

  if v_open_required > 0 then
    return jsonb_build_object(
      'ok', false,
      'code', 'required_checks_open',
      'open_required_checks', v_open_required
    );
  end if;

  update public.context_sessions
  set
    status = 'completed',
    result = coalesce(p_result, '{}'::jsonb),
    result_type = nullif(trim(coalesce(p_result_type,'')),''),
    closure_reason = coalesce(nullif(trim(coalesce(p_closure_reason,'')),''),'goal_achieved'),
    closed_at = now(),
    updated_at = now()
  where id = p_context_session_id
  returning * into v_session;

  insert into public.memory_events(
    profile_id, context_session_id, mode, title, summary, memory_type, event_type, importance, result, confidence
  ) values (
    v_session.profile_id,
    v_session.id,
    'system',
    v_session.title,
    trim(p_summary),
    'result',
    'session_closed',
    'high',
    coalesce(p_result, '{}'::jsonb),
    1.0
  );

  return jsonb_build_object(
    'ok', true,
    'context_session_id', v_session.id,
    'status', v_session.status,
    'result', v_session.result
  );
end;
$$;

revoke all on function public.orb_open_context_session_v1(uuid,text,text,text,jsonb) from public;
revoke all on function public.orb_complete_check_v1(uuid,jsonb,text) from public;
revoke all on function public.orb_complete_session_v1(uuid,jsonb,text,text,text) from public;

grant execute on function public.orb_open_context_session_v1(uuid,text,text,text,jsonb) to service_role;
grant execute on function public.orb_complete_check_v1(uuid,jsonb,text) to service_role;
grant execute on function public.orb_complete_session_v1(uuid,jsonb,text,text,text) to service_role;

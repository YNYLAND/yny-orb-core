create or replace function public.build_orb_guide_packet(
  p_profile_id uuid,
  p_conversation_session_id text,
  p_mode_key text default 'system',
  p_message text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_mode jsonb;
  v_discourse jsonb := '[]'::jsonb;
  v_agreements jsonb := '[]'::jsonb;
  v_profile_memory jsonb := '[]'::jsonb;
  v_summaries jsonb := '[]'::jsonb;
  v_sessions jsonb := '[]'::jsonb;
  v_events jsonb := '[]'::jsonb;
  v_state_deltas jsonb := '[]'::jsonb;
  v_access jsonb := '{}'::jsonb;
  v_capabilities jsonb := '[]'::jsonb;
begin
  select to_jsonb(m)
  into v_mode
  from (
    select mode_key, display_name, purpose, frame, success_metric,
           retrieval_policy, capability_policy, agent_policy, offer_policy
    from public.orb_modes
    where mode_key = coalesce(nullif(p_mode_key, ''), 'system')
      and is_active = true
    limit 1
  ) m;

  if v_mode is null then
    select to_jsonb(m)
    into v_mode
    from (
      select mode_key, display_name, purpose, frame, success_metric,
             retrieval_policy, capability_policy, agent_policy, offer_policy
      from public.orb_modes
      where mode_key = 'system'
      limit 1
    ) m;
  end if;

  if p_conversation_session_id is not null then
    select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at asc, x.id asc), '[]'::jsonb)
    into v_discourse
    from (
      select id, role, message, mode, created_at
      from public.conversation_messages
      where session_id = p_conversation_session_id
      order by created_at desc, id desc
      limit 12
    ) x;

    select coalesce(jsonb_agg(to_jsonb(x) order by x.block_index asc), '[]'::jsonb)
    into v_summaries
    from (
      select block_index, title, summary, tags, mode, message_from, message_to
      from public.session_summary_blocks
      where session_id = p_conversation_session_id
      order by block_index desc
      limit 6
    ) x;
  end if;

  if p_profile_id is not null then
    select coalesce(jsonb_agg(to_jsonb(x) order by x.priority asc, x.updated_at desc), '[]'::jsonb)
    into v_agreements
    from (
      select id, memory_type, title, content, importance, confidence,
             epistemic_status, tags, updated_at,
             case importance when 'core' then 0 when 'high' then 1 when 'normal' then 2 else 3 end as priority
      from public.profile_memory
      where profile_id = p_profile_id
        and is_active = true
        and (
          memory_type in ('agreement','preference','decision','workflow')
          or tags && array['agreement','rule','contract','behavior']::text[]
        )
      order by priority asc, updated_at desc
      limit 8
    ) x;

    select coalesce(jsonb_agg(to_jsonb(x) order by x.priority asc, x.updated_at desc), '[]'::jsonb)
    into v_profile_memory
    from (
      select id, memory_type, title, content, importance, confidence,
             epistemic_status, tags, updated_at,
             case importance when 'core' then 0 when 'high' then 1 when 'normal' then 2 else 3 end as priority
      from public.profile_memory
      where profile_id = p_profile_id
        and is_active = true
        and not (
          memory_type in ('agreement','preference','decision','workflow')
          or tags && array['agreement','rule','contract','behavior']::text[]
        )
      order by priority asc, updated_at desc
      limit 16
    ) x;

    select coalesce(jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'title', s.title,
        'goal', s.goal,
        'context', s.context,
        'status', s.status,
        'current_state', s.current_state,
        'target_state', s.target_state,
        'linked_entities', s.linked_entities,
        'parent_session_id', s.parent_session_id,
        'updated_at', s.updated_at,
        'checks', coalesce((
          select jsonb_agg(jsonb_build_object(
            'id', c.id,
            'title', c.title,
            'description', c.description,
            'status', c.status,
            'required', c.required,
            'result', c.result,
            'capability_keys', c.capability_keys,
            'sort_order', c.sort_order
          ) order by c.sort_order asc, c.created_at asc)
          from public.session_checks c
          where c.context_session_id = s.id
            and c.status <> 'cancelled'
        ), '[]'::jsonb)
      )
      order by case s.status when 'active' then 0 when 'blocked' then 1 when 'paused' then 2 else 3 end, s.updated_at desc
    ), '[]'::jsonb)
    into v_sessions
    from (
      select *
      from public.context_sessions
      where profile_id = p_profile_id
        and status in ('active','blocked','paused')
      order by case status when 'active' then 0 when 'blocked' then 1 when 'paused' then 2 else 3 end, updated_at desc
      limit 5
    ) s;

    select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb)
    into v_events
    from (
      select id, session_id, context_session_id, mode, title, summary,
             memory_type, event_type, importance, tags, result, confidence, created_at
      from public.memory_events
      where profile_id = p_profile_id
      order by created_at desc
      limit 12
    ) x;

    select coalesce(jsonb_agg(to_jsonb(x) order by x.created_at desc), '[]'::jsonb)
    into v_state_deltas
    from (
      select id, context_session_id, title, summary, event_type,
             state_delta, result, confidence, created_at
      from public.memory_events
      where profile_id = p_profile_id
        and (
          state_delta is not null
          or result is not null
          or event_type in ('action_completed','result','session_closed','check_completed')
        )
      order by created_at desc
      limit 10
    ) x;

    select jsonb_build_object(
      'activated_skills', coalesce((
        select jsonb_agg(jsonb_build_object(
          'skill_key', ps.skill_key,
          'display_name', sc.display_name,
          'mode_key', sc.mode_key,
          'price_yny', sc.price_yny,
          'sale_state', sc.sale_state
        ) order by sc.sort_order asc nulls last, ps.skill_key asc)
        from public.profile_skills ps
        left join public.skill_catalog sc on sc.skill_key = ps.skill_key
        where ps.profile_id = p_profile_id
      ), '[]'::jsonb)
    )
    into v_access;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'capability_key', c.capability_key,
    'display_name', c.display_name,
    'description', c.description,
    'category', c.category,
    'system_status', c.system_status,
    'produces', c.produces,
    'can_close', c.can_close,
    'requires_modes', c.requires_modes,
    'requires_skills', c.requires_skills,
    'requires_connectors', c.requires_connectors,
    'activation_type', c.activation_type,
    'activation_price_yny', c.activation_price_yny,
    'execution_profile', mp.execution_profile,
    'mode_available', coalesce(mp.is_available, c.category = 'CORE'),
    'provider_strategy', mp.provider_strategy,
    'multi_agent', mp.multi_agent,
    'mode_config', mp.config
  ) order by
    case c.system_status when 'available' then 0 when 'implemented' then 1 when 'planned' then 2 else 3 end,
    c.category,
    c.capability_key
  ), '[]'::jsonb)
  into v_capabilities
  from public.orb_capabilities c
  left join public.orb_capability_mode_profiles mp
    on mp.capability_key = c.capability_key
   and mp.mode_key = coalesce(nullif(p_mode_key, ''), 'system')
  where c.system_status <> 'deprecated'
    and (
      c.category = 'CORE'
      or mp.is_available = true
      or coalesce(nullif(p_mode_key, ''), 'system') = any(coalesce(c.requires_modes, array[]::text[]))
    );

  return jsonb_build_object(
    'packet_version', 'guide-packet-v0',
    'generated_at', now(),
    'input', jsonb_build_object(
      'profile_id', p_profile_id,
      'conversation_session_id', p_conversation_session_id,
      'mode_key', coalesce(nullif(p_mode_key, ''), 'system'),
      'message', p_message
    ),
    'mode', coalesce(v_mode, '{}'::jsonb),
    'recent_discourse', v_discourse,
    'semantic_summary', v_summaries,
    'active_agreements', v_agreements,
    'profile_memory', v_profile_memory,
    'context_sessions', v_sessions,
    'recent_memory_events', v_events,
    'recent_state_deltas', v_state_deltas,
    'actor_access', v_access,
    'orb_max_candidates', v_capabilities,
    'guide_rules', jsonb_build_object(
      'discourse_is_sensor', true,
      'context_before_capability', true,
      'understand_before_handoff', true,
      'horizon_before_offer', true,
      'offer_requires_interest', true,
      'target_is_state_change', true
    )
  );
end;
$$;

revoke all on function public.build_orb_guide_packet(uuid,text,text,text) from public;
revoke all on function public.build_orb_guide_packet(uuid,text,text,text) from anon;
revoke all on function public.build_orb_guide_packet(uuid,text,text,text) from authenticated;
grant execute on function public.build_orb_guide_packet(uuid,text,text,text) to service_role;

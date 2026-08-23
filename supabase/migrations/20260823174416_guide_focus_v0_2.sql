update public.orb_modes
set offer_policy = coalesce(offer_policy,'{}'::jsonb) || jsonb_build_object(
  'progressive_disclosure', jsonb_build_array('horizon','current_interest','relevant_capability','offer_if_interest'),
  'horizon_can_be_proactive', true,
  'card_requires_explicit_interest', true,
  'offer_only_after_interest', true,
  'do_not_lead_with_price', true
), updated_at = now()
where mode_key='system';

create or replace function public.build_orb_guide_focus(
  p_profile_id uuid,
  p_conversation_session_id text,
  p_mode_key text default 'system',
  p_message text default null,
  p_explicit_interest boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_packet jsonb;
  v_session jsonb := '{}'::jsonb;
  v_check jsonb := '{}'::jsonb;
  v_orb_max jsonb := '[]'::jsonb;
  v_focus_caps jsonb := '[]'::jsonb;
  v_horizon_caps jsonb := '[]'::jsonb;
  v_interest_caps jsonb := '[]'::jsonb;
  v_offer_policy jsonb := '{}'::jsonb;
  v_card_allowed boolean := false;
  v_focus_source text := 'none';
  v_interest_source text := 'session';
begin
  v_packet := public.build_orb_guide_packet(p_profile_id,p_conversation_session_id,p_mode_key,p_message);

  select value into v_session
  from jsonb_array_elements(coalesce(v_packet->'context_sessions','[]'::jsonb))
  order by case value->>'status' when 'active' then 0 when 'blocked' then 1 when 'paused' then 2 else 3 end
  limit 1;

  if v_session is not null and v_session <> '{}'::jsonb then
    select value into v_check
    from jsonb_array_elements(coalesce(v_session->'checks','[]'::jsonb))
    where value->>'status' not in ('completed','cancelled')
    order by
      case
        when coalesce((value->>'required')::boolean,false) and value->>'status'='actionable' then 0
        when coalesce((value->>'required')::boolean,false) and value->>'status'='blocked' then 1
        when coalesce((value->>'required')::boolean,false) and value->>'status'='potential' then 2
        when value->>'status'='actionable' then 3
        when value->>'status'='blocked' then 4
        else 5
      end,
      coalesce((value->>'sort_order')::int,999)
    limit 1;
    if v_check is not null and v_check <> '{}'::jsonb then
      v_focus_source := 'open_check';
    else
      v_check := '{}'::jsonb;
      v_focus_source := 'active_session';
    end if;
  else
    v_session := '{}'::jsonb;
    v_check := '{}'::jsonb;
  end if;

  select coalesce(jsonb_agg(jsonb_build_object(
    'capability_key',c.capability_key,
    'display_name',c.display_name,
    'description',c.description,
    'category',c.category,
    'system_status',c.system_status,
    'produces',c.produces,
    'can_close',c.can_close,
    'activation_type',c.activation_type,
    'activation_price_yny',c.activation_price_yny,
    'requires_modes',c.requires_modes,
    'requires_skills',c.requires_skills,
    'requires_connectors',c.requires_connectors,
    'mode_available',coalesce(mp.is_available,c.category='CORE' or coalesce(p_mode_key,'system')=any(coalesce(c.requires_modes,array[]::text[]))),
    'execution_profile',mp.execution_profile,
    'provider_strategy',mp.provider_strategy,
    'multi_agent',mp.multi_agent,
    'mode_config',mp.config
  ) order by case c.system_status when 'available' then 0 when 'implemented' then 1 when 'planned' then 2 else 3 end,c.category,c.capability_key),'[]'::jsonb)
  into v_orb_max
  from public.orb_capabilities c
  left join public.orb_capability_mode_profiles mp
    on mp.capability_key=c.capability_key and mp.mode_key=coalesce(p_mode_key,'system')
  where c.system_status <> 'deprecated';

  select coalesce(jsonb_agg(cap),'[]'::jsonb) into v_focus_caps
  from (
    select c.value as cap
    from jsonb_array_elements(v_orb_max) c
    where c.value->>'capability_key' in (
      select jsonb_array_elements_text(coalesce(v_check->'capability_keys','[]'::jsonb))
    )
    order by case c.value->>'system_status' when 'available' then 0 when 'implemented' then 1 when 'planned' then 2 else 3 end
    limit 8
  ) q;

  select coalesce(jsonb_agg(cap),'[]'::jsonb) into v_horizon_caps
  from (
    select distinct on (c.value->>'capability_key') c.value as cap
    from jsonb_array_elements(v_orb_max) c
    where c.value->>'capability_key' in (
      select jsonb_array_elements_text(coalesce(ch.value->'capability_keys','[]'::jsonb))
      from jsonb_array_elements(coalesce(v_session->'checks','[]'::jsonb)) ch
      where ch.value->>'status' in ('potential','actionable','blocked')
    )
    order by c.value->>'capability_key',case c.value->>'system_status' when 'available' then 0 when 'implemented' then 1 when 'planned' then 2 else 3 end
    limit 12
  ) q;

  if coalesce(trim(p_message),'') <> '' then
    select coalesce(jsonb_agg(cap),'[]'::jsonb) into v_interest_caps
    from (
      select c.value as cap
      from jsonb_array_elements(v_orb_max) c
      where lower(p_message) like '%' || lower(replace(c.value->>'capability_key','_',' ')) || '%'
         or lower(p_message) like '%' || lower(c.value->>'display_name') || '%'
      order by case c.value->>'system_status' when 'available' then 0 when 'implemented' then 1 when 'planned' then 2 else 3 end
      limit 6
    ) q;
  end if;

  if jsonb_array_length(v_interest_caps)>0 then
    v_interest_source:='explicit_capability_mention';
  elsif v_check<>'{}'::jsonb then
    v_interest_source:='open_check';
  elsif v_session<>'{}'::jsonb then
    v_interest_source:='session_goal';
  else
    v_interest_source:='current_message';
  end if;

  v_offer_policy := coalesce(v_packet->'mode'->'offer_policy','{}'::jsonb);
  v_card_allowed := p_explicit_interest
    and jsonb_array_length(v_interest_caps)>0
    and coalesce((v_offer_policy->>'offer_only_after_interest')::boolean,true);

  return jsonb_build_object(
    'focus_version','guide-focus-v0.2',
    'mode_key',coalesce(p_mode_key,'system'),
    'focus_source',v_focus_source,
    'point_of_interest',jsonb_build_object(
      'source',v_interest_source,
      'message',p_message,
      'explicit_capability_interest',v_interest_caps
    ),
    'current_session',case when v_session='{}'::jsonb then null else jsonb_build_object(
      'id',v_session->'id','title',v_session->'title','goal',v_session->'goal','status',v_session->'status',
      'current_state',v_session->'current_state','target_state',v_session->'target_state'
    ) end,
    'current_focus_check',case when v_check='{}'::jsonb then null else v_check end,
    'focus_capabilities',v_focus_caps,
    'horizon_capabilities',v_horizon_caps,
    'actor_access',coalesce(v_packet->'actor_access','{}'::jsonb),
    'active_agreements',coalesce(v_packet->'active_agreements','[]'::jsonb),
    'memory_context',jsonb_build_object(
      'recent_discourse',coalesce(v_packet->'recent_discourse','[]'::jsonb),
      'semantic_summary',coalesce(v_packet->'semantic_summary','[]'::jsonb),
      'profile_memory',coalesce(v_packet->'profile_memory','[]'::jsonb),
      'recent_state_deltas',coalesce(v_packet->'recent_state_deltas','[]'::jsonb)
    ),
    'retrieval_status',jsonb_build_object(
      'direct_recent_discourse',true,
      'direct_semantic_summary',true,
      'direct_profile_memory',true,
      'vector_similarity_retrieval',false,
      'knowledge_item_retrieval',false,
      'graph_relation_expansion',false
    ),
    'disclosure',jsonb_build_object(
      'sequence',coalesce(v_offer_policy->'progressive_disclosure',jsonb_build_array('horizon','current_interest','relevant_capability','offer_if_interest')),
      'show_horizon',true,
      'expand_current_interest',true,
      'explicit_interest',p_explicit_interest,
      'offer_card_allowed',v_card_allowed,
      'lead_with_price',false
    ),
    'candidate_state_transition',case when v_session='{}'::jsonb then null else jsonb_build_object(
      'from',v_session->'current_state,
      'toward',v_session->'target_state,
      'through_check',case when v_check='{}'::jsonb then null else v_check->'title' end
    ) end,
    'core_rules',jsonb_build_object(
      'diagnose_before_execute',true,
      'context_before_capability',true,
      'system_sees_orb_max',true,
      'rights_gate_execution_not_understanding',true,
      'horizon_before_offer',true,
      'offer_requires_explicit_interest',true,
      'do_not_make_system_stupid',true,
      'target_is_state_change',true
    )
  );
end;
$$;

revoke all on function public.build_orb_guide_focus(uuid,text,text,text,boolean) from public;
revoke all on function public.build_orb_guide_focus(uuid,text,text,text,boolean) from anon;
revoke all on function public.build_orb_guide_focus(uuid,text,text,text,boolean) from authenticated;
grant execute on function public.build_orb_guide_focus(uuid,text,text,text,boolean) to service_role;

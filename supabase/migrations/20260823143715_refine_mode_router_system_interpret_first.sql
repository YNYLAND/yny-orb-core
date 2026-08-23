create or replace function public.orb_mode_route_v1(
  p_mode_key text,
  p_message text,
  p_has_ynychat boolean default false,
  p_has_corp boolean default false
)
returns jsonb
language plpgsql
stable
set search_path to 'public'
as $function$
declare
  v_mode text := lower(coalesce(p_mode_key, 'system'));
  v_message text := lower(trim(coalesce(p_message, '')));
  v_personal_deep_work boolean := false;
  v_explicit_neo_world boolean := false;
  v_route text;
  v_recommended_mode text := null;
  v_handoff_status text := 'none';
  v_offer_allowed boolean := false;
  v_policy jsonb := '{}'::jsonb;
  v_system_obligation text := null;
  v_handoff_after_interpretation boolean := false;
begin
  if v_mode not in ('system','ynychat','corp') then
    v_mode := 'system';
  end if;

  select jsonb_build_object(
    'purpose', purpose,
    'frame', frame,
    'success_metric', success_metric,
    'retrieval_policy', retrieval_policy,
    'capability_policy', capability_policy,
    'agent_policy', agent_policy,
    'offer_policy', offer_policy
  )
  into v_policy
  from public.orb_modes
  where mode_key = v_mode;

  if v_message = '' then
    return jsonb_build_object(
      'router_version','mode_router_v1_1',
      'mode',v_mode,
      'route','NOOP',
      'recommended_mode',null,
      'handoff_status','none',
      'handoff_after_interpretation',false,
      'system_obligation',null,
      'offer_allowed',false,
      'policy',coalesce(v_policy,'{}'::jsonb)
    );
  end if;

  v_explicit_neo_world := v_message ~ '(neo world|нео мир|yny|юни|профил|баланс|модул|скил|сущност|паспорт|creator|креатор|dao|nft|токен|кошел|ликвид|амбассад|юрисдикц|каталог|wiki|вики|guide|гид|tree|way|road)';

  v_personal_deep_work := v_message ~ '(разбер|проанализир|интерпретир|оцени|отредактир|перепиш|напиш|сочин|придумай|разработай|помоги.*(проект|бизнес|стратег|стих|текст|книг|курс|идею)|исследуй.*(для меня|мою|мой|мои)|обсудим|поговорим.*(о|про))';

  if v_mode = 'system' then
    if v_personal_deep_work and not v_explicit_neo_world then
      v_route := 'SYSTEM_INTERPRET_THEN_HANDOFF';
      v_system_obligation := 'ACTOR_MANIFESTATION_INTERPRETATION';
      v_recommended_mode := 'ynychat';
      v_handoff_status := case when p_has_ynychat then 'available' else 'locked' end;
      v_handoff_after_interpretation := true;
      v_offer_allowed := false;
    else
      v_route := 'NEO_WORLD_ENTITY_FIRST';
      v_system_obligation := 'NEO_WORLD_ENTITY_RESOLUTION';
    end if;
  elsif v_mode = 'ynychat' then
    v_route := 'HANDLE_IN_MODE';
  else
    v_route := 'MULTI_AGENT_PRODUCTION';
  end if;

  return jsonb_build_object(
    'router_version','mode_router_v1_1',
    'mode',v_mode,
    'route',v_route,
    'recommended_mode',v_recommended_mode,
    'handoff_status',v_handoff_status,
    'handoff_after_interpretation',v_handoff_after_interpretation,
    'system_obligation',v_system_obligation,
    'offer_allowed',v_offer_allowed,
    'policy',coalesce(v_policy,'{}'::jsonb)
  );
end;
$function$;

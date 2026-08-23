-- ORB MODE ROUTER v1
-- Deterministic baseline boundary between SYSTEM / YNY CHAT / CORP.
-- This is intentionally conservative and cheap. Guide Core may add richer semantic routing later.

create or replace function public.orb_mode_route_v1(
  p_mode_key text,
  p_message text,
  p_has_ynychat boolean default false,
  p_has_corp boolean default false
)
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
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
      'router_version','mode_router_v1',
      'mode',v_mode,
      'route','NOOP',
      'recommended_mode',null,
      'handoff_status','none',
      'offer_allowed',false,
      'policy',coalesce(v_policy,'{}'::jsonb)
    );
  end if;

  -- Explicit Neo World/system vocabulary keeps SYSTEM inside its own frame.
  v_explicit_neo_world := v_message ~ '(neo world|нео мир|yny|юни|профил|баланс|модул|скил|сущност|паспорт|creator|креатор|dao|nft|токен|кошел|ликвид|амбассад|юрисдикц|каталог|wiki|вики|guide|гид|tree|way|road)';

  -- Deep personal/open-domain work that belongs to YNY CHAT when SYSTEM is active.
  v_personal_deep_work := v_message ~ '(разбер|проанализир|интерпретир|оцени|отредактир|перепиш|напиш|сочин|придумай|разработай|помоги.*(проект|бизнес|стратег|стих|текст|книг|курс|идею)|исследуй.*(для меня|мою|мой|мои)|обсудим|поговорим.*(о|про))';

  if v_mode = 'system' then
    if v_personal_deep_work and not v_explicit_neo_world then
      v_route := 'YNY_CHAT_IF_DEEP_PERSONAL_ANALYSIS';
      v_recommended_mode := 'ynychat';
      v_handoff_status := case when p_has_ynychat then 'available' else 'locked' end;
      -- Interest in a task is enough to reveal the route, but not enough to create a purchase OFFER.
      v_offer_allowed := false;
    else
      v_route := 'NEO_WORLD_ENTITY_FIRST';
    end if;
  elsif v_mode = 'ynychat' then
    v_route := 'HANDLE_IN_MODE';
  else
    v_route := 'MULTI_AGENT_PRODUCTION';
  end if;

  return jsonb_build_object(
    'router_version','mode_router_v1',
    'mode',v_mode,
    'route',v_route,
    'recommended_mode',v_recommended_mode,
    'handoff_status',v_handoff_status,
    'offer_allowed',v_offer_allowed,
    'policy',coalesce(v_policy,'{}'::jsonb)
  );
end;
$$;

comment on function public.orb_mode_route_v1(text,text,boolean,boolean) is
'Deterministic ORB mode boundary. SYSTEM defaults to Neo World entity-first; deep personal/open-domain work routes toward YNY CHAT; YNY CHAT handles personally; CORP uses multi-agent production.';

revoke all on function public.orb_mode_route_v1(text,text,boolean,boolean) from public;
grant execute on function public.orb_mode_route_v1(text,text,boolean,boolean) to authenticated, service_role;

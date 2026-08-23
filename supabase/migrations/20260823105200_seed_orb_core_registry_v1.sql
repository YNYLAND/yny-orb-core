-- Seed the machine-readable ORB CORE registry used in YNY DEV.

insert into public.orb_capabilities
(capability_key, display_name, description, system_status, category, produces, can_close, activation_type)
values
('ACTOR_CONTEXT','Actor Context','Понимание текущего состояния и контекста актора.','available','CORE',array['actor_state'],array['context_understanding'],'core'),
('ASSIS','ASSIS','Исполнитель действий от имени актора в разрешённых пределах.','planned','ACTION',array['external_action'],array['execution'],'activation'),
('DISCOURSE_CONTEXT','Discourse Context','Различение дискурса пользователя и рабочего контекста ситуации.','available','CORE',array['context_model'],array['context_understanding'],'core'),
('DYNAMIC_UI','Dynamic UI','Сбор ответа из динамических контентных и action-блоков.','planned','CORE',array['ui_blocks'],array['presentation'],'core'),
('ENTITY_GRAPH','Entity Graph','Паспорта сущностей и связи Neo World.','planned','KNOWLEDGE',array['entity_context'],array['entity_navigation'],'core'),
('GEO','GEO','Геолокация, карты, маршруты и отношения мест.','planned','WORLD',array['map','route'],array['navigation','discovery'],'activation'),
('GESTALT_ENGINE','Gestalt Engine','Цели, чеки и закрытие гештальтов через результаты.','implemented','CORE',array['checks','results'],array['goal_completion'],'core'),
('GUIDE_CORE','Guide Core','Сбор релевантного контекста и сценария перед ответом Орба.','planned','CORE',array['guide_packet'],array['next_action'],'core'),
('IMAGE','IMAGE','Понимание, создание и редактирование изображений.','planned','CREATE',array['image'],array['visualization','packaging'],'activation'),
('INFOTEKA','INFOTEKA','Импорт, структурирование и сохранение внешних источников.','implemented','KNOWLEDGE',array['knowledge_blocks'],array['knowledge_capture'],'activation'),
('MEMORY','Memory','Рабочая, событийная и долговременная память актора.','implemented','CORE',array['memory'],array['continuity'],'core'),
('MULTI_AGENT_ORCHESTRATION','Multi-Agent Orchestration','Оркестрация множества моделей и ассистентов.','planned','CORP',array['agent_workflow'],array['complex_execution'],'corp'),
('PUBLISH','PUBLISH','Публикация результатов во внутренних и внешних каналах.','planned','ACTION',array['publication'],array['distribution'],'activation'),
('SESSION_ENGINE','Session Engine','Параллельные смысловые сессии и их жизненный цикл.','implemented','CORE',array['context_session'],array['goal_tracking'],'core'),
('SITE_PAGE','SITE / PAGE','Создание страниц и сайтов.','planned','CREATE',array['site','page'],array['publication','presentation'],'activation'),
('SMM_AUTOPILOT','SMM AUTOPILOT','Автономный контур распространения контента.','implemented','ACTION',array['social_distribution'],array['distribution','promotion'],'activation'),
('VIDEO','VIDEO','Создание и работа с видео.','planned','CREATE',array['video','preview'],array['visualization','promotion','distribution'],'activation'),
('WEB','WEB','Поиск и чтение открытого интернета.','planned','KNOWLEDGE',array['research'],array['research'],'activation')
on conflict (capability_key) do update set
  display_name = excluded.display_name,
  description = excluded.description,
  system_status = excluded.system_status,
  category = excluded.category,
  produces = excluded.produces,
  can_close = excluded.can_close,
  activation_type = excluded.activation_type,
  updated_at = now();

insert into public.orb_capability_mode_profiles
(capability_key, mode_key, execution_profile, is_available, provider_strategy, multi_agent, config)
values
('IMAGE','corp','max',true,'multi_provider',true,'{"critic":true,"variants":"many","art_director":true}'::jsonb),
('IMAGE','ynychat','personal',true,'preferred_provider',false,'{"variants":"few"}'::jsonb),
('MULTI_AGENT_ORCHESTRATION','corp','max',true,'multi_model',true,'{"required_mode":"corp"}'::jsonb),
('VIDEO','corp','max',true,'multi_provider',true,'{"critic":true,"previews":"many","selection":true,"comparator":true}'::jsonb),
('VIDEO','system','neo_world',true,'internal_catalog',false,'{"focus":"existing_video_and_creator_paths"}'::jsonb),
('VIDEO','ynychat','personal',true,'preferred_provider',false,'{"previews":"few","cheap_templates":true}'::jsonb),
('WEB','corp','max',true,'multi_researcher',true,'{"critic":true,"verifier":true,"synthesis":true,"researchers":"many"}'::jsonb),
('WEB','ynychat','personal',true,'preferred_provider',false,'{"researchers":1}'::jsonb)
on conflict (capability_key, mode_key) do update set
  execution_profile = excluded.execution_profile,
  is_available = excluded.is_available,
  provider_strategy = excluded.provider_strategy,
  multi_agent = excluded.multi_agent,
  config = excluded.config,
  updated_at = now();

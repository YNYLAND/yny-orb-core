update public.orb_modes
set
  purpose = case mode_key
    when 'system' then 'Помогать актору пользоваться Neo World, раскрывать доступные возможности системы, получать из неё пользу и вносить в неё новые сущности, контент, связи и транзакции.'
    when 'ynychat' then 'Быть личным интеллектуальным инструментом актора для свободного диалога, развития, творчества, обучения, исследований и достижения личных целей.'
    when 'corp' then 'Масштабировать цели актора в многоагентную производственную работу: параллельные исследования, вариативное производство, критика, отбор и исполнение.'
  end,
  frame = case mode_key
    when 'system' then 'NEO_WORLD_FRAME'
    when 'ynychat' then 'ACTOR_DEVELOPMENT_FRAME'
    when 'corp' then 'MULTI_AGENT_PRODUCTION_FRAME'
  end,
  success_metric = case mode_key
    when 'system' then 'Актор получил ценность из Neo World или внёс в Neo World новое состояние: сущность, контент, связь, активацию, транзакцию или действие.'
    when 'ynychat' then 'Актор лучше понял задачу, развил идею или получил полезный результат по выбранной им теме.'
    when 'corp' then 'Сложная цель актора разложена, параллельно обработана несколькими специализированными ролями и доведена до качественного проверяемого результата.'
  end,
  retrieval_policy = case mode_key
    when 'system' then jsonb_build_object(
      'entity_first', true,
      'neo_world_internal_first', true,
      'external_general_knowledge_as_primary', false,
      'show_existing_in_neo_world', true,
      'show_how_to_manifest_if_missing', true,
      'profile_memory_scope', 'only_relevant_to_neo_world_interaction'
    )
    when 'ynychat' then jsonb_build_object(
      'entity_first', false,
      'neo_world_internal_first', false,
      'external_general_knowledge_as_primary', true,
      'profile_memory_scope', 'relevant_personal_context'
    )
    when 'corp' then jsonb_build_object(
      'entity_first', false,
      'neo_world_internal_first', false,
      'external_general_knowledge_as_primary', true,
      'profile_memory_scope', 'relevant_personal_and_project_context',
      'parallel_retrieval', true
    )
  end,
  capability_policy = case mode_key
    when 'system' then jsonb_build_object(
      'conversation_scope', 'neo_world_use_and_contribution',
      'free_personal_analysis', false,
      'creator_handoff_allowed', true,
      'ynychat_handoff_required_for_personal_deep_work', true,
      'system_goal', 'neo_world_participation_and_transactions'
    )
    when 'ynychat' then jsonb_build_object(
      'conversation_scope', 'open_personal',
      'free_personal_analysis', true,
      'execution_profile', 'personal',
      'inherits_system_knowledge', true
    )
    when 'corp' then jsonb_build_object(
      'conversation_scope', 'open_personal_and_business',
      'free_personal_analysis', true,
      'execution_profile', 'max',
      'inherits_ynychat_capabilities', true,
      'multi_provider_variants', true
    )
  end,
  agent_policy = case mode_key
    when 'system' then jsonb_build_object('multi_agent', false, 'assistant_budget', 'minimal')
    when 'ynychat' then jsonb_build_object('multi_agent', false, 'assistant_budget', 'normal')
    when 'corp' then jsonb_build_object('multi_agent', true, 'assistant_budget', 'max', 'parallel_roles', true, 'critic', true, 'comparator', true)
  end,
  offer_policy = case mode_key
    when 'system' then jsonb_build_object(
      'goal', 'reveal_relevant_neo_world_opportunities',
      'offer_only_after_interest', true,
      'activation_language', true,
      'no_pressure', true
    )
    when 'ynychat' then jsonb_build_object('offer_only_after_interest', true, 'no_pressure', true)
    when 'corp' then jsonb_build_object('offer_only_after_interest', true, 'no_pressure', true, 'show_max_execution_value', true)
  end,
  updated_at = now()
where mode_key in ('system','ynychat','corp');

create table if not exists public.orb_mode_acceptance_cases (
  case_key text primary key,
  mode_key text not null references public.orb_modes(mode_key),
  user_input text not null,
  must_do jsonb not null default '[]'::jsonb,
  must_not_do jsonb not null default '[]'::jsonb,
  expected_route text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.orb_mode_acceptance_cases enable row level security;

insert into public.orb_mode_acceptance_cases(case_key, mode_key, user_input, must_do, must_not_do, expected_route)
values
  (
    'system_poem_analysis_boundary',
    'system',
    'Послушай мой стих и подробно его разберём.',
    '["Проверить, как произведение/автор/проект представлены в Neo World","Показать, что можно проявить или создать в Neo World","Предложить YNY CHAT только если пользователь хочет именно личный литературный анализ"]'::jsonb,
    '["Давать полноценный бесплатный литературный разбор как YNY CHAT","Вести длинную творческую работу вне Neo World frame"]'::jsonb,
    'YNY_CHAT_IF_DEEP_PERSONAL_ANALYSIS'
  ),
  (
    'system_entity_violets',
    'system',
    'Фиалки',
    '["Искать сущность и паспорт ФИАЛКА/ФИАЛКИ в Neo World","Показать связанные объекты, контент, товары и пути проявления","Если паспорта нет — предложить Creator и создание паспорта"]'::jsonb,
    '["Начинать общую ботаническую энциклопедию","Заменять отсутствующие внутренние данные внешним общим знанием"]'::jsonb,
    'NEO_WORLD_ENTITY_FIRST'
  ),
  (
    'ynychat_poem_analysis',
    'ynychat',
    'Послушай мой стих и подробно его разберём.',
    '["Провести содержательный литературный анализ","Следовать теме пользователя","Использовать релевантный личный контекст"]'::jsonb,
    '["Сводить разговор к Neo World без необходимости"]'::jsonb,
    'HANDLE_IN_MODE'
  ),
  (
    'corp_poetry_collection',
    'corp',
    'Разбери сборник стихов и подготовь его к публикации.',
    '["Разложить задачу на параллельные роли","Сделать несколько независимых оценок/редактур","Свести результаты, сравнить варианты и подготовить финальный пакет"]'::jsonb,
    '["Работать как одиночный простой чат без оркестрации"]'::jsonb,
    'MULTI_AGENT_PRODUCTION'
  )
on conflict (case_key) do update set
  mode_key = excluded.mode_key,
  user_input = excluded.user_input,
  must_do = excluded.must_do,
  must_not_do = excluded.must_not_do,
  expected_route = excluded.expected_route,
  is_active = true,
  updated_at = now();

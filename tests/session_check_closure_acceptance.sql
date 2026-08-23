-- Semantic session/check acceptance test.
-- Purpose: prove that a session cannot close before required achieved results exist.
-- Run in DEV only.

with opened as (
  select public.orb_open_context_session_v1(
    null,
    'TEST · Semantic closure',
    'Prove required checks gate session completion',
    'DEV acceptance test',
    '[{"title":"Required achieved result","required":true,"status":"actionable","capability_keys":["GESTALT_ENGINE"]}]'::jsonb
  ) as payload
), ids as (
  select (payload->>'context_session_id')::uuid as session_id from opened
), check_row as (
  select sc.id as check_id, ids.session_id
  from ids
  join public.session_checks sc on sc.context_session_id = ids.session_id
  where sc.required = true
  limit 1
), premature as (
  select public.orb_complete_session_v1(
    session_id,
    '{"state":"too_early"}'::jsonb,
    'test',
    'This must not close yet.'
  ) as payload
  from check_row
), completed_check as (
  select public.orb_complete_check_v1(
    check_id,
    '{"achieved":true}'::jsonb,
    'Required result achieved.'
  ) as payload,
  session_id
  from check_row
), completed_session as (
  select public.orb_complete_session_v1(
    session_id,
    '{"state":"done"}'::jsonb,
    'test',
    'Session completed after required result.'
  ) as payload
  from completed_check
)
select
  (select payload->>'code' from premature) = 'required_checks_open' as blocked_before_result,
  (select payload->>'status' from completed_check) = 'completed' as check_completed,
  (select payload->>'status' from completed_session) = 'completed' as session_completed_after_result;

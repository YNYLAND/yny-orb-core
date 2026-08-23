-- Mode Router v1 acceptance test.
-- Expected result: every row passed = true.

select
  case_key,
  mode_key,
  expected_route,
  (public.orb_mode_route_v1(mode_key, user_input, true, true)->>'route') as actual_route,
  (public.orb_mode_route_v1(mode_key, user_input, true, true)->>'route') = expected_route as passed
from public.orb_mode_acceptance_cases
where is_active
order by case_key;

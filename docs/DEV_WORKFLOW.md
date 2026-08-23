# ORB CORE development workflow

## Current state

- Production Supabase project: `YNY PLATFORMA`.
- Supabase organization: `YNY GAME` (Free plan at audit time).
- Supabase preview branches are not enabled.
- GitHub development branch: `orb-core-dev`.
- Separate Supabase DEV project: `YNY DEV`.

## Canonical workflow until Supabase Branching is enabled

1. `main` represents production-intended canonical state.
2. New ORB CORE schema/function work is prepared on `orb-core-dev`.
3. Production Supabase remains unchanged while migrations are drafted and reviewed.
4. `YNY DEV` is the isolated test environment for schema, functions and acceptance tests.
5. DEV receives schema/function changes first.
6. Tests and security review must pass before a GitHub PR is merged to `main` and before production SQL/functions are changed.

## Later, with Supabase Branching

Git branch remains the version-history source.
Supabase branch becomes the isolated executable environment for the corresponding Git branch/PR.

Git answers: "what changed, when, and why?"
Supabase Branch answers: "does this version actually run safely in an isolated Supabase environment?"

## Migration rule

Every intentional database change must end as a versioned migration artifact in Git. Direct production SQL is exceptional and must be followed by a committed migration/baseline update.

## Current ORB CORE workstream

1. Baseline current production schema and functions.
2. Fix/contain critical payment RPC exposure before broader refactors.
3. Maintain `orb_capabilities` as ORB MAX ontology.
4. Maintain semantic `orb_modes` instead of duplicating mode tables.
5. Maintain `orb_capability_mode_profiles`.
6. Build semantic memory layer: `context_sessions`, `session_checks`, event linkage.
7. Build Mode Router and Guide Core retrieval packet.
8. Integrate execution capabilities incrementally.

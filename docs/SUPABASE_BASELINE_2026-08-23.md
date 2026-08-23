# Supabase baseline — YNY PLATFORMA

Date: 2026-08-23
Project: `YNY PLATFORMA` (`dcjsuhtwncyhwensjbdt`)
Status: read-only audit snapshot. No production schema changes applied by this audit.

## 1. Environment state

- Production project is ACTIVE_HEALTHY.
- Region: eu-central-1.
- Postgres: 17.6.
- Supabase migration history: empty.
- Supabase development branches: none.
- Current architecture therefore exists as live database state + Edge Function versions rather than a formal migration chain.

## 2. Logical packages found

### ACTOR / ACCESS
- profiles
- profile_links
- profile_pin_credentials
- profile_pin_attempts
- orb_sessions
- orb_handoffs
- orb_auth_handoffs
- profile_skills

### ORB MEMORY
- conversation_messages
- session_summary_blocks
- memory_events
- profile_memory
- knowledge_items

Existing memory Edge Functions:
- memory-summary-builder
- profile-memory-builder
- summary-embed
- memory-api
- knowledge-embed / vectorize-knowledge-items

Important semantic rule confirmed from live code:
`session_summary_blocks` are periodic semantic summaries derived directly from raw `conversation_messages`; they are NOT semantic session closures.

Planned additions:
- context_sessions
- session_checks
- optional later profile_chronicle_snapshots

### ORB SYSTEM / CAPABILITIES
- orb_modes
- skill_catalog
- skill_dependencies
- profile_skills

Current `orb_modes` already contains:
- system
- ynychat
- corp

Current `skill_catalog` contains commercial activations for YNY CHAT, WEB SERF, IMAGE, VIDEO, CONNECT, GEO, CORP, INFOTEKA and other modules.

Architectural distinction to preserve:
- `orb_capabilities` = what ORB MAX can conceptually/systemically do.
- `skill_catalog` = commercial activations / entitlements sold to the actor.
- Some capabilities are intrinsic and never sold; some capabilities map to one or more commercial skills.

Planned additions:
- orb_capabilities
- orb_capability_mode_profiles
- semantic expansion of existing orb_modes rather than creating a duplicate mode table.

### ECONOMY
- profile_balances
- balance_topup_orders
- balance_transactions
- neo_world_fee_account
- neo_world_fee_ledger

Key SQL functions:
- credit_mono_topup
- purchase_skill
- purchase_list_slots
- get_neo_world_fee_balance

## 3. Current mode interpretation target

SYSTEM
- primary frame: Neo World
- purpose: show what exists in Neo World, what actor can take/use, what actor can contribute/create, and relevant potential system opportunities.

YNY CHAT
- personal reasoning/development mode.
- broad-topic conversation and execution using actor-activated capabilities.

CORP
- inherits the actor's YNY CHAT capability stack.
- same cognitive canon, but maximum execution profile: multi-agent orchestration, multiple models/providers, variants, previews, critic/comparator/selection, broader ASSIS usage.

The flagship model remains primary in every mode; Luna/Terra/other models are helpers, not mode identities.

## 4. Existing memory pipeline confirmed

conversation_messages
→ memory-summary-builder
→ session_summary_blocks

memory_events
→ profile-memory-builder
→ profile_memory + embeddings

The new semantic process layer is additive:

context_sessions
→ session_checks
→ action/result
→ closed session result
→ memory_event(session_closed / action_completed / result ...)

A closed check represents an achieved state/result, not a pending to-do item.

## 5. Important security finding — HIGH PRIORITY

`public.credit_mono_topup(...)` is currently:
- `SECURITY DEFINER`
- executable by `anon`
- executable by `authenticated`

The function accepts `p_amount_uah` and credits YNY based on that supplied amount when the referenced top-up order is pending. The production `mono-process-topups` Edge Function invokes this RPC using the service-role credential, so public RPC execution is not required for the intended flow.

Risk: a client that can invoke the RPC directly may be able to credit a pending order without Monobank being the source of truth.

Recommended fix after explicit production-change review:
1. REVOKE EXECUTE on `credit_mono_topup` from PUBLIC / anon / authenticated.
2. Grant execution only to the privileged server role required by the payment worker.
3. Verify `mono-process-topups` still credits a controlled test order correctly.
4. Review whether `mono-process-topups` itself should remain `verify_jwt=false`; if it is an internal polling endpoint, add a server-side secret or another invocation guard.

No security change was applied during this audit.

## 6. Branching / version-control strategy

Git is the source of version history for schema migrations, Edge Function source and ORB-CORE registries.

Supabase Branching is an isolated executable environment used to apply/test those versions without touching production. It complements Git; it does not replace Git history.

Until paid Supabase Branching is enabled:
- keep production unchanged except for deliberate reviewed fixes;
- build a Git baseline and migration sequence;
- optionally use a second Free Supabase project as a DEV copy if the organization's quota/cost confirms it is free;
- later move to a real Supabase development branch without changing the canonical migration history.

## 7. Next safe actions

1. Continue read-only audit of RLS, functions and Edge Functions.
2. Capture current live schema as a baseline in Git/migrations.
3. Convert `schema/001_orb_memory_core.sql` from conceptual draft into a migration compatible with the real live schema.
4. Design `orb_capabilities` and `orb_capability_mode_profiles` against the existing `skill_catalog`/`orb_modes` tables.
5. Create a DEV environment only after Supabase reports the exact organization-specific cost and the user approves it.
6. Apply and verify new ORB Memory Core work in DEV before production.

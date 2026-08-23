# ORB CORE

Version: 0.1.0
Status: canonical draft

ORB CORE fixes two fundamental system objects:

1. **ORB MAX ONTOLOGY** — the canonical model of what Orb can potentially do at maximum capability.
2. **ORB MEMORY CORE** — the canonical model of how Orb understands an Actor over time: discourse, context, parallel semantic sessions, checks, events, results and long-term memory.

These objects are mode-independent. SYSTEM, YNY CHAT and CORP use the same cognitive core and the same Actor memory. Modes change frame, retrieval priorities, execution profile and available resources — not the fundamental logic of thinking.

## Core cognitive canon

- **ACTOR FIRST**: Actor determines direction; Orb supplies depth, continuity and execution.
- **Listen to discourse; answer context**: wording and emotion are signals, not automatically the subject of the answer.
- **No request — no topic expansion. A real request — no artificial poverty of response.**
- **Do not optimize a dead-end scenario; change the scenario.**
- **Orb thinks from ORB MAX, but acts through Actor access and current mode.**
- **Orb does not try to activate everything. It derives a Target Actor Stack only for the Actor's manifested goal.**
- **The unit of progress is a state-changing action/transaction, not another message.**
- **A semantic session lives until its goal is achieved, cancelled, reframed, merged or consciously closed.**
- **Completed session results form the Actor's achievement history.**

## Two independent memory streams

### Raw-discourse summaries
`session_summary_blocks` remain periodic summaries made directly from raw `conversation_messages`. They are independent of semantic-session boundaries. They exist so later passes can detect repeated themes, accumulated patterns and latent vectors across time.

### Semantic sessions
`context_sessions` are parallel goal/process lines inferred and maintained by Orb. Their lifecycle is tracked through `session_checks` and `memory_events`. Closure belongs to the session itself via its status and result fields; it is not a summary block.

## Main machine registries

- `registry/orb_capabilities.yaml` — ORB MAX capability ontology.
- `registry/orb_modes.yaml` — mode semantics and inheritance.
- `registry/orb_capability_mode_profiles.yaml` — how the same capability executes differently by mode.
- `schema/001_orb_memory_core.sql` — additive Supabase/Postgres draft for semantic sessions and checks.

## Runtime composition

Before an answer, Guide Core should eventually assemble a compact Guide Packet from:

- current Actor State;
- current request envelope;
- relevant semantic sessions;
- open checks and recent events;
- relevant profile memory;
- relevant raw-discourse summaries when needed;
- relevant ORB MAX capabilities;
- current mode profile;
- Actor activations and runtime permissions.

The flagship model then produces the visible response and dynamic interface. Helpers (Luna, Terra and, in CORP, additional specialist models/agents) prepare or execute parts of the work without changing the single Orb identity.

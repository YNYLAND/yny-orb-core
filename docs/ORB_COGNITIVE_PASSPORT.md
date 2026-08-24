# ORB COGNITIVE PASSPORT

## Identity

Orb is one flagship intelligence with one cognitive core, one continuous memory architecture and many execution surfaces. SYSTEM, YNY CHAT and CORP are modes of the same Orb, not separate minds.

Canonical rule:

> Orb thinks from the maximum of its possibilities and acts within the current mode, Actor rights and Actor will.

## The skeleton

```text
ACTOR / DISCOURSE
        ↓
INPUT ADAPTERS
Telegram / Web / Unity / voice / future devices
        ↓
MODE ROUTER
        ↓
COGNITIVE RETRIEVAL
├─ recent discourse
├─ semantic summary blocks
├─ profile memory / agreements
├─ knowledge / Infoteka vectors
├─ entity + relation graph
├─ context sessions + checks
├─ state deltas / results
├─ ORB MAX
└─ Actor access / connectors
        ↓
GUIDE PACKET
        ↓
GUIDE FOCUS
        ↓
FLAGSHIP ORB
        ↓
RESPONSE PLAN
├─ discourse / text
├─ dynamic UI intents
├─ action intents
├─ handoff intents
└─ memory / state-change intents
        ↓
POLICY + RIGHTS + SERVER VALIDATION
        ↓
EXECUTION / RENDER
Telegram / Web / Unity / 3D / VR / Metaverse / external systems
        ↓
RESULT
        ↓
STATE DELTA + MEMORY EVENT + CHECK UPDATE
        ↺
```

## Status legend

- **PROD WORKING** — verified in current YNY PLATFORMA.
- **DEV WORKING** — implemented and tested in YNY DEV, not connected to production Orb yet.
- **PARTIAL** — a real piece works, but it is not yet the canonical architecture.
- **PLANNED** — architecture defined, execution not implemented yet.

## 1. Flagship cognition

**PROD WORKING**

- GPT flagship response generation.
- Last-message discourse context.
- Current mode state.
- Existing prompt traits: feel context, follow the Actor, synthesize meaning, use appropriate initiative, do not invent unavailable system processes.

**DEV WORKING**

- explicit mode cognition policies;
- SYSTEM interpret-first canon;
- mode acceptance cases;
- Guide Packet and Guide Focus.

**PLANNED**

- production integration of Mode Router + Guide before every flagship response.

## 2. Modes

**SYSTEM** — enter context through discourse, diagnose Actor state/intention, project into Neo World, reveal a broad horizon and route; stop before long-form execution.

**YNY CHAT** — work directly with personal/content material.

**CORP** — organize multi-agent, multi-tool production processes.

Progressive SYSTEM disclosure:

```text
HORIZON
→ CURRENT INTEREST
→ RELEVANT CAPABILITY
→ OFFER ONLY AFTER EXPLICIT INTEREST
```

This is a system law, not a personal preference.

## 3. Memory

### L0 Raw discourse — PROD WORKING
`conversation_messages`

Primary historical record.

### L1 Semantic summary blocks — PROD WORKING
`session_summary_blocks`

Semantic compression of raw dialogue. Blocks are embedded and can later be retrieved by meaning.

### L2 Memory events — PROD WORKING
`memory_events`

Important goals, decisions, agreements, project state, results and other semantic events.

### L2b Durable profile memory — PROD WORKING
`profile_memory`

Immediate event mirroring gives continuity; a background librarian later classifies durable vs redundant/temporary memory. Durable entries have embeddings.

### L3 Profile Chronicle / Summary of Summaries — PLANNED

Higher-order periodic synthesis across months of discourse, sessions, results, entities and state deltas. Must preserve epistemic status: observed / confirmed / inferred.

## 4. Knowledge and Infoteka

### Legacy knowledge vector store — PROD WORKING / PARTIAL
`knowledge_items`

The current store supports embeddings and vector lookup, but is structurally poor.

### Infoteka knowledge-block factory — PLANNED

```text
SOURCE
→ remove noise
→ semantic segmentation
→ normalize
→ metadata / scope / provenance
→ entity + relation links
→ embedding
→ reusable knowledge blocks
```

Personal, project, system and public scopes are expected.

## 5. Retrieval

### Legacy system knowledge vector RAG — PROD WORKING

Current orb-api embeds the message and retrieves top knowledge_items.

### Summary/profile memory direct loading — PROD WORKING

Current orb-api loads summaries and profile memory directly.

### Unified Guide Retrieval — PLANNED

```text
REQUEST EMBEDDING
├─ old semantic summaries
├─ profile memory
├─ personal Infoteka
├─ project Infoteka
└─ system/public knowledge
        ↓
rank / dedupe
        ↓
graph expansion
        ↓
Guide Packet
```

## 6. Entity and relation graph

**PARTIAL STATIC / PLANNED RUNTIME**

The interface repository already contains a static entity and relation registry, including PROFILE, AVATAR, MODAL, GAME, SPACE, 3D, VR, MV and other Neo World objects.

A real runtime graph is not yet implemented in Supabase.

Future graph connects Actor, entities, projects, artifacts, knowledge blocks, sessions, checks, capabilities, places, products, offers and transactions.

Vector answers “what is semantically relevant?” Graph answers “what is structurally connected?”

## 7. Semantic sessions and Gestalt

**DEV WORKING**

`context_sessions` + `session_checks`.

- parallel semantic processes inside one chat;
- current state and target state;
- required/optional checks;
- result required to close meaningful checks;
- session closure blocked while required checks remain open.

**PLANNED**

Automatic Context Session Detector and automatic check lifecycle based on real actions/results.

## 8. State Delta / Time River

**DEV CONCEPT + PARTIAL EVENTS**

Primary value unit is not a message but a meaningful state transition.

```text
STATE A → Δ → STATE B
```

Deltas include Actor, artifact, entity, transaction, capability, project, knowledge and world changes.

Future Time River / River of Good News can expose verified positive state changes across YNY LAND.

## 9. Guide

### Guide Packet — DEV WORKING

Deterministic service-only state assembler.

Contains mode, discourse, summaries, agreements, profile memory, sessions/checks, events/deltas, access and ORB MAX.

### Guide Focus v0.2 — DEV WORKING

Deterministic attention selector.

Keeps visible:
- current Actor state;
- target state;
- current point of interest;
- nearest open check;
- relevant ORB MAX;
- possible state transition;
- progressive disclosure / offer gate.

### Guide Retrieval — PLANNED

Adds vector and graph retrieval before final packet/focus assembly.

## 10. ORB MAX

ORB MAX is the ontology of what Orb can conceptually understand and potentially execute through present or future capabilities. It is larger than the current commercial catalog.

It must include cognition, knowledge, creation, action, Neo World infrastructure, identity, spaces/worlds and CORP orchestration.

Rights and activation gate execution, not understanding.

## 11. Dynamic Interface

**PROD PARTIAL**

Current orb-api can receive a hidden `[UI]` block from the model, sanitize it, and return validated UI. It already has primitive buttons, skill cards, modes and LIST state.

However the grammar is fragmented across orb-api and channel adapters.

**PLANNED / NEXT**

Canonical Dynamic Interface Language: a semantic UI AST produced by Orb, validated server-side and rendered by Telegram/Web/Unity/3D/VR adapters.

## 12. Action execution

**PROD WORKING / FRAGMENTED**

Current server supports mode state, catalog, skill cards, skill purchase, YNY CHAT enter/exit, LIST state/purchase and some Telegram-specific profile creation.

**PLANNED**

Unified Action Executor:

```text
ORB ACTION INTENT
→ policy / identity / rights validation
→ executor
→ result
→ state delta
→ UI/result block
```

Profile creation should become `PROFILE_CREATE` in this executor rather than a Telegram phrase special-case.

## 13. Profile creation today

**PROD WORKING, TELEGRAM-SPECIFIC**

Current Telegram flow intercepts the phrase “создай профиль” before flagship cognition:

```text
Telegram message
→ webhook phrase match
→ check profile_links
→ if absent find next profile number
→ create profiles row
→ create Telegram profile_link
→ reply with profile ID
→ Open profile button
```

A separate legacy `orb-create-profile` function duplicates much of this logic.

Target architecture:

```text
Actor intent
→ PROFILE_CREATE capability
→ trusted identity context
→ server executor
→ profile + link
→ STATE DELTA: no_profile → profile_exists
→ PROFILE_CARD + OPEN_CABINET
```

## 14. CORP

**PLANNED**

Multi-agent orchestration, independent researchers/critics/designers/coders/executors, parallel variants, verification and synthesis while the flagship Orb remains the single identity.

## 15. World / immersive layer

**SYSTEM ENTITIES EXIST / ORB MAX EXPANSION IN DEV**

Neo World already contains concepts and commercial/system objects for AVATAR, SPACE, 3D, VR, MV/METAVERSE and GAME modes. These must be first-class ORB MAX capabilities so SYSTEM can reason in a wide horizon.

Possible Actor path can therefore include not only posts or websites but:

```text
PROFILE
→ AVATAR
→ CONTENT / BOOK / SITE
→ CONNECT / DISTRIBUTION
→ 3D SPACE / VR / METAVERSE
→ OWN WORLD
→ GAME / EXPERIENCE
→ OWN SYSTEM
→ OFFERS / TRANSACTIONS / COMMUNITY
```

The horizon is shown as possibility, not as an immediate sales catalog.

## Final anatomy

Orb is not a chat with plugins. The intended organism is:

- **brain** — flagship cognition;
- **sensory system** — discourse + adapters;
- **memory** — raw / summaries / events / durable memory / chronicle;
- **library** — Infoteka knowledge blocks;
- **association system** — vectors;
- **structural model** — entity/relation graph;
- **executive attention** — Guide Packet + Focus;
- **self-model** — ORB MAX;
- **rights model** — Actor access;
- **intentional processes** — semantic sessions/checks;
- **metabolism/time** — state deltas;
- **language/body** — Dynamic Interface;
- **hands** — Action Executor / ASSIS / connectors;
- **workforce** — CORP agents;
- **world body** — pages, avatars, 3D/VR/metaverses, games and Actor-created systems.

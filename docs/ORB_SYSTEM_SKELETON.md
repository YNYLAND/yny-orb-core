# ORB SYSTEMS SYSTEM — SKELETON

## Purpose

This document is the master anatomy of Orb: the **system of systems** that shows which major organs exist, what each organ owns, and how state flows through the organism.

The master sheet is **Sheet 0** of the future printable Orb Systems Atlas. Every numbered system below should later have its own printable sheet with purpose, inputs, outputs, internal modules, dependencies, live status, current implementation and roadmap.

## Central core

At the center is the **Flagship Orb Core** — the single conversational/intellectual identity of Orb.

It is not a replacement for the systems below. The systems supply memory, information, self-model, scenarios, language, interface, actions and world state around the flagship intelligence.

```text
                         ORB SYSTEMS SYSTEM
                                 │
                                 ▼
                         FLAGSHIP ORB CORE
                                 │
      ┌──────────────────────────┼──────────────────────────┐
      ▼                          ▼                          ▼
  cognition                   memory                  self-model
      │                          │                          │
      └───────────────┬──────────┴──────────┬───────────────┘
                      ▼                     ▼
                   GUIDE                ORB MAX
                      │
                      ▼
               ORB LANGUAGE
                      │
                      ▼
             DYNAMIC INTERFACE
                      │
                      ▼
                    ACTOR
                      │
                      ▼
                  ACTIONS
                      │
                      ▼
                 STATE DELTA
                      │
             MEMORY / GRAPH / WORLD
                      │
                      └──────────────► next cycle
```

# Master system map

## 1. Cognitive System

Purpose: understand Actor discourse and current situation.

Owns:
- discourse interpretation;
- Actor intent / need / goal inference;
- context formation;
- SYSTEM / YNY CHAT / CORP cognition frame;
- request interpretation before execution;
- reasoning boundaries between diagnosis/orientation and actual work.

Working/building:
- flagship dialogue;
- recent discourse;
- Mode Cognition policies;
- Mode Router v1 in DEV;
- SYSTEM interpret-first canon.

Planned:
- richer Actor-state inference;
- epistemic labels: observed / confirmed / inferred;
- semantic session detection.

## 2. Memory System

Purpose: continuity of the Actor–Orb relationship and history.

Owns:
- raw conversation memory;
- semantic summaries;
- memory events;
- durable profile memory;
- agreements and preferences;
- embeddings of memory layers;
- summary-of-summaries / profile chronicle later.

Working in production:
- `conversation_messages`;
- `session_summary_blocks`;
- summary embeddings;
- `memory_events`;
- event → working profile-memory bridge;
- `profile_memory`;
- memory embeddings;
- automatic memory workers / cron.

Planned:
- active agreement model;
- profile chronicle;
- cross-session vector retrieval;
- memory → state-delta relations.

## 3. Information System

Purpose: provide the information environment Orb can retrieve and reason over.

This name intentionally replaces the former umbrella term `Knowledge / Infoteka System` so it does not conflict with the commercial/product module **INFOTEKA**.

Owns:
- system knowledge;
- Wiki/entity information;
- knowledge blocks;
- imported documents/materials;
- source provenance;
- information normalization;
- semantic chunking;
- information embeddings;
- personal/system information scopes;
- retrieval-ready informational blocks.

Current embryo:
- `knowledge_items` + embeddings;
- vector matching of system knowledge.

Target pipeline:

```text
SOURCE
↓
INGEST
↓
CLEAN / NORMALIZE
↓
SEMANTIC BLOCKS
↓
METADATA / SOURCE / SCOPE
↓
EMBEDDINGS
↓
ENTITY / RELATION SEEDS
↓
INFORMATION RETRIEVAL
```

INFOTEKA becomes one module/tool that can feed this system, not the system name itself.

## 4. Guide System

Purpose: orchestrate what context, information, memory and system elements are relevant now.

Owns:
- Guide Packet;
- Guide Focus;
- scenario construction;
- retrieval orchestration;
- relevant memory selection;
- relevant information selection;
- ORB MAX exposure;
- Actor access view;
- session/check/state view;
- selection of server blocks and AI slots for Dynamic Interface.

Working in DEV:
- Guide Packet v0;
- Guide Focus v0.

Building:
- vector retrieval;
- broad horizon reasoning;
- scenario module composition.

Planned:
- graph expansion;
- multi-stage retrieval/reranking;
- scenario evaluation.

## 5. Orb Language System

Purpose: define the channel-independent semantic vocabulary Orb uses to express meaning and action.

Core rule:

> Stable meaning, living expression.

Vocabulary examples:
- TEXT;
- CARD;
- PROFILE;
- ENTITY;
- BUTTON;
- ACTION;
- POTENTIAL_ACTION;
- OFFER;
- ACCEPT;
- CHECK;
- STATE_DELTA;
- RESULT;
- WAY;
- TREE;
- MAP;
- AVATAR;
- SPACE;
- WORLD;
- PORTAL.

Safe visible wording may adapt to Actor language, tone and relationship while semantic action stays stable.

## 6. Dynamic Interface System

Purpose: compose and render Orb Language using server-side blocks and live state.

Owns:
- block registry;
- server content retrieval;
- response templates;
- image/video/text reuse;
- cards/containers;
- optional AI reasoning slots;
- channel-independent UI AST;
- render adapters for Telegram / Web / Unity / 3D / VR.

Core principle:

> Do not spend flagship intelligence to reproduce data already stored on the server.

## 7. Orb Self-Awareness System

Purpose: maintain Orb's operational self-model.

Owns:
- which Orb systems exist;
- current health/status of systems;
- what is implemented / planned / unavailable;
- boundaries and limitations;
- current runtime environment;
- self-diagnostics;
- ability to distinguish understanding from execution rights.

This system answers:

> What am I, what organs do I have, what is their current state, and what can I truthfully claim about myself?

## 8. Capability & Mode System / ORB MAX

Purpose: maintain the maximum capability horizon and execution profiles by mode.

Formula:

```text
ORB MAX
∩ MODE EXECUTION PROFILE
∩ ACTOR ACCESS
∩ ACTOR WILL
∩ CURRENT SESSION
→ AVAILABLE EXECUTION STACK
```

Understanding may see planned or locked capabilities even when execution is not available.

Includes current/future capability families such as:
- WEB;
- IMAGE;
- VIDEO;
- PROFILE_CREATE;
- GEO;
- CONNECT;
- SMM_AUTOPILOT;
- AVATAR;
- SPACE / 3D / VR;
- METAVERSE;
- WORLD_BUILDER;
- GAME_BUILDER;
- EXPERIENCE_BUILDER;
- SYSTEM_BUILDER;
- MULTI_AGENT_ORCHESTRATION.

## 9. Action & Execution System

Purpose: turn Actor-authorized semantic actions into safe executable operations.

Owns:
- action identity;
- action validation;
- accept/consent rules;
- executor dispatch;
- rollback/retry where possible;
- result capture;
- action logs;
- production of evidence for State Delta.

Examples:
- create profile;
- create entity;
- publish;
- switch mode;
- activate capability;
- connect account;
- send message;
- create world object.

Core rule:

> Acceptance is execution when the action, consequences and Actor intent are sufficiently clear.

## 10. Integration System — External World → Orb

Purpose: safely bring external-world data, signals and context **into Orb**.

Direction:

```text
EXTERNAL WORLD
→ INTEGRATION SYSTEM
→ INFORMATION / MEMORY / GRAPH / GUIDE / ORB
```

Owns:
- inbound adapters;
- source ingestion;
- webhooks/events;
- files and documents;
- external messages;
- feeds;
- external API responses;
- normalization into Orb-readable structures;
- provenance and source identity;
- inbound permissions/privacy.

Examples:
- Telegram incoming message;
- imported Instagram/YouTube content;
- bank transaction event;
- calendar event;
- uploaded file;
- external API payload;
- Unity/IoT/world-state event.

## 11. Connector System — Orb → External World

Purpose: safely let Orb reach and act **outward into external systems**.

Direction:

```text
ORB / ACTION SYSTEM
→ CONNECTOR SYSTEM
→ EXTERNAL WORLD
```

Owns:
- connector registry;
- provider adapters;
- external authentication/tokens;
- supported outbound capabilities;
- external action execution;
- service-specific constraints;
- external result/error normalization;
- connection health.

Examples:
- publish to Instagram / TikTok / YouTube;
- send email/message;
- create calendar event;
- call external API;
- booking;
- payment provider action;
- deploy/publish site;
- control authorized external service.

Integration and Connector Systems are related but intentionally separate because their trust, authorization and data-flow semantics differ.

## 12. Entity / Relation / Graph System

Purpose: represent what exists and how it is connected.

Owns:
- entities;
- passports;
- relations;
- personal graph;
- system graph;
- graph projections;
- relation provenance/confidence;
- path/neighbor expansion.

Target objects include:
- Actor/profile;
- project;
- artifact/work;
- method;
- service;
- organization;
- place;
- information block;
- site;
- avatar;
- world;
- token/NFT;
- capability;
- session/result/state delta.

## 13. Gestalt / Session / State System

Purpose: model movement from state A to state B.

Owns:
- semantic session;
- goal;
- check;
- result;
- evidence;
- state delta;
- closure;
- River of Time / change history projection.

Core rule:

> A closed check means a verifiable state change, not a decorative checkbox.

State changes may come from checks, transactions, artifacts, entities, activations, publications, connections and external actions.

## 14. Economy & Offer System

Purpose: govern value, commercial offers and financial state.

Owns:
- product/module catalog;
- prices;
- offers;
- offer gating;
- accept → transaction;
- balances;
- ownership/entitlements;
- payment state;
- transaction history;
- fees/tax mechanics;
- economic state deltas.

Server is the source of truth for money and consequences.

## 15. Multiverse / 3D World System

Purpose: support embodied/spatial forms of Neo World.

Owns/plans:
- avatars;
- 3D spaces;
- VR spaces;
- metaverses;
- portals;
- world objects;
- games;
- experiences;
- simulations;
- Actor consultation/presence inside worlds;
- world/system creation.

This is both an execution surface and a major ORB MAX horizon.

## 16. Infrastructure System

Purpose: provide the runtime foundation all Orb systems depend on.

Owns:
- PostgreSQL/Supabase;
- vector storage/indexes;
- file/object storage;
- Edge Functions/APIs;
- queues/background jobs;
- cron;
- secrets/Vault;
- auth/security primitives;
- monitoring/logs;
- deployment/versioning;
- GitHub/CI/CD;
- hosting/CDN/network infrastructure.

# Directional map of the world boundary

```text
                      EXTERNAL WORLD
                      ▲            │
                      │            ▼
              CONNECTOR          INTEGRATION
                SYSTEM             SYSTEM
                      ▲            │
                      │            ▼
                    ACTION        GUIDE
                      ▲            │
                      └────── ORB ─┘
```

- **Integration System** makes the external world readable by Orb.
- **Connector System** makes Orb capable of acting in the external world.

# Development status legend

- `working_prod` — live and used in production;
- `working_dev` — implemented/tested in YNY DEV;
- `building` — current implementation target;
- `planned` — architecture established but not yet implemented;
- `concept` — useful horizon, not yet sufficiently specified.

# Skeleton rule

Before adding a feature, determine which organ owns it.

Examples:
- remembering an agreement → Memory System;
- importing a PDF → Integration System → Information System;
- retrieving a relevant Wiki block → Information System / Guide;
- understanding why it matters now → Cognitive System / Guide;
- knowing METAVERSE exists → Self-Awareness + ORB MAX;
- expressing `OPEN_WORLD` → Orb Language;
- rendering the world card → Dynamic Interface System;
- validating an action → Action System;
- posting to Instagram → Connector System;
- validating price/access → Economy System;
- recording what changed → State System;
- linking the result to Actor/project/world → Entity/Graph System.

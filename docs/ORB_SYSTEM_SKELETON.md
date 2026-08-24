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

Purpose: maintain the informational field Orb can use as knowledge and source material.

This is not the Memory System and not the product/module **INFOTEKA**.

It answers:

> What information can Orb know, retrieve, verify, compare and reason over?

Owns:
- `knowledge_items` and future richer knowledge blocks;
- Wiki / canonical system information;
- trusted sources of truth;
- documents and structured reference materials;
- system and personal informational scopes;
- automatic information-memory builders;
- semantic chunking;
- embeddings and vector indexes;
- provenance / source metadata;
- freshness / version state;
- retrieval-ready informational blocks.

Typical sources may include:
- Neo World canonical data;
- Wiki;
- imported documents;
- connected external sources accessed through Connector System;
- actor-authorized archives;
- feeds/news/data streams;
- information produced by modules such as INFOTEKA.

Current embryo:
- `knowledge_items` + embeddings;
- vector matching of system knowledge.

Target information pipeline:

```text
SOURCE MATERIAL
↓
CLEAN / NORMALIZE
↓
SEMANTIC BLOCKS
↓
METADATA / SOURCE / SCOPE / VERSION
↓
EMBEDDINGS
↓
RETRIEVAL
↓
GUIDE / FLAGSHIP ORB
```

Entity/relation candidates may be emitted from information blocks, but becoming part of the unified Neo World graph requires **Integration System**.

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

## 10. Integration System — Into the Unified Neo World Field

Purpose: decide whether something external, local or newly created may become a **recognized part of the unified Orb / Neo World field**.

Integration is not transport and not “reading the outside world”. It is a one-way admission/manifestation process.

Canonical direction:

```text
CANDIDATE OBJECT / DATA / ACTOR / PROJECT / ARTIFACT / KNOWLEDGE
↓
INTEGRATION RULES
↓
VALIDATION / NORMALIZATION / RIGHTS / NEO WORLD STANDARDS
↓
ACCEPTED OR REJECTED
↓
IF ACCEPTED:
ENTITY / PASSPORT / CONTENT / RELATIONS / GRAPH / INDEX / VISIBILITY / ECONOMIC RIGHTS
↓
BECOMES PART OF THE UNIFIED FIELD
```

This system answers:

> Can this become part of Neo World, under what rules, in what canonical form, with what relations, visibility and rights?

Owns/plans:
- integration rules and standards;
- PLUS / MINUS integration lists in the first stage;
- eligibility / rejection reasons;
- canonical type mapping;
- normalization into Neo World forms;
- entity/passport creation or update;
- integration into unified graph;
- relation creation;
- visibility/discoverability state;
- provenance / authorship;
- rights / ownership / attribution;
- content integration;
- monetization eligibility for later consumption by other Actors;
- integration audit trail;
- integration state delta.

Examples of things that may pass Integration:
- person / profile / actor representation;
- project;
- artifact;
- book;
- method;
- service;
- event;
- news item;
- knowledge block;
- site;
- organization;
- place;
- token/NFT/world object;
- external data imported through Connector System.

Important distinction:

> Connector can fetch or send something without integrating it.
>
> Integration begins only when the system decides that the object should become part of the shared Neo World field.

This is the system behind the SYSTEM-mode **INTEGRATION** surface next to GUIDE and WIKI.

## 11. Connector System — Orb ↔ External World

Purpose: provide the two-way technical and authorization bridge between Orb and external systems.

Canonical direction:

```text
ORB ⇄ CONNECTOR SYSTEM ⇄ EXTERNAL WORLD
```

Connector System does not itself decide that imported information becomes part of the unified Neo World graph. It only provides controlled access and transport.

Owns:
- connector registry;
- provider adapters;
- external authentication/tokens;
- inbound reads/subscriptions;
- outbound actions;
- service-specific scopes and permissions;
- external event/webhook handling;
- external result/error normalization;
- connection health;
- consent and revocation;
- channel identity mapping.

Examples:
- Orb plugin in ChatGPT;
- importing authorized ChatGPT history into profile memory;
- connecting Telegram account for reading authorized information;
- connecting TikTok / Instagram / YouTube / Facebook;
- publishing content outward;
- reading external feeds;
- email / calendar / messenger integrations;
- bank/payment provider connection;
- Cloudflare / GitHub / Supabase / external API connections;
- Unity / external application links.

Two-way rule:

```text
READ / RECEIVE  ← Connector → external source
ACT / SEND      Connector → external destination
```

A Connector may feed:
- Cognitive System;
- Information System;
- Memory System;
- Action System;
- Integration System.

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

Integration System is one of the main gates through which new objects and relations enter the shared graph.

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

State changes may come from checks, transactions, artifacts, entities, activations, publications, connections, integrations and external actions.

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

Integration System may later determine whether an integrated object/content block is eligible for monetized reuse inside Neo World.

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

# Boundary map

```text
                         EXTERNAL WORLD
                               ▲  │
                               │  ▼
                    ┌────────────────────┐
                    │  CONNECTOR SYSTEM  │
                    │     two-way        │
                    └─────────┬──────────┘
                              │
                     reads / sends / acts
                              │
              ┌───────────────┴────────────────┐
              ▼                                ▼
       ORB INTERNAL SYSTEMS              INTEGRATION CANDIDATE
                                               │
                                               ▼
                                    ┌────────────────────┐
                                    │ INTEGRATION SYSTEM │
                                    │     one-way gate   │
                                    └─────────┬──────────┘
                                              │ accepted
                                              ▼
                                   UNIFIED NEO WORLD FIELD
                                   GRAPH / MEMORY / CONTENT
                                   ENTITIES / RIGHTS / INDEX
```

- **Connector System** connects Orb and external systems in both directions.
- **Integration System** decides whether something crosses the boundary into the unified Neo World field and becomes part of the whole.
- **Information System** stores and retrieves information Orb can use, whether or not every informational item has been integrated as a shared Neo World entity.

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
- connecting a Telegram account → Connector System;
- reading authorized Telegram content → Connector System → Information/Memory;
- deciding that one imported item becomes part of Neo World → Integration System;
- creating its passport and links → Integration System + Entity/Graph System;
- retrieving a relevant Wiki/knowledge block → Information System / Guide;
- understanding why it matters now → Cognitive System / Guide;
- knowing METAVERSE exists → Self-Awareness + ORB MAX;
- expressing `OPEN_WORLD` → Orb Language;
- rendering the world card → Dynamic Interface System;
- validating an action → Action System;
- posting to Instagram → Connector System;
- validating price/access → Economy System;
- recording what changed → State System;
- linking the result to Actor/project/world → Entity/Graph System.

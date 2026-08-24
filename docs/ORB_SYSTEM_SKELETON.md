# ORB SYSTEM SKELETON

## Purpose

This document is the high-level anatomy of Orb. It separates cognitive organs, memory, language, interface/runtime, capabilities, entities and state-change mechanics so new development can be attached to the correct layer.

## 1. Cognitive System

Purpose: understand the Actor's discourse and current situation, preserve mode frame, detect goals/gaps, and decide what matters now.

### Working now
- flagship Orb conversation;
- recent discourse context;
- SYSTEM / YNY CHAT / CORP mode state;
- Mode Cognition policies in YNY DEV;
- Mode Router v1 in DEV;
- Guide Packet v0 in DEV;
- Guide Focus v0 in DEV;
- semantic sessions/check primitives in DEV.

### Building now
- richer Guide focus;
- broad ORB MAX horizon;
- semantic session detection;
- check/state-delta integration;
- SYSTEM interpret-first / work-boundary behavior.

### Planned
- vector-guided retrieval across memory layers;
- graph expansion;
- agreement detector;
- profile chronicle / summary-of-summaries;
- richer actor-state inference with epistemic labels.

## 2. Memory System

Purpose: continuity, agreements, goals, projects, semantic history, retrieval and long-term state.

### Working now in production
- `conversation_messages` raw discourse;
- `session_summary_blocks` semantic compression;
- summary embeddings;
- `memory_events` event capture;
- immediate event → profile-memory bridge;
- `profile_memory` durable memory;
- profile-memory embeddings;
- automatic memory workers / cron;
- `knowledge_items` vectorized knowledge blocks.

### Building now
- Guide retrieval from vector memory instead of only recent rows;
- agreement-state handling;
- event/result/state-delta relationships.

### Planned
- Infoteka as knowledge-block factory;
- personal and system knowledge scopes;
- source metadata and provenance;
- summary-of-summaries / profile chronicle;
- graph memory and entity relations;
- cross-session semantic retrieval.

## 3. Orb Language System

Purpose: define the semantic vocabulary Orb can use to express meaning and action independent of Telegram/Web/Unity.

Examples:
- TEXT
- CARD
- PROFILE
- ENTITY
- BUTTON
- ACTION
- OFFER
- ACCEPT
- CHECK
- STATE_DELTA
- WAY
- TREE
- MAP
- AVATAR
- SPACE
- WORLD
- PORTAL

Core rule:

> Stable meaning, living expression.

The action is canonical; safe labels may adapt to language, tone and relationship.

## 4. Dynamic Interface System

Purpose: compose Orb Language using server data and render it in the current channel.

Responsibilities:
- block registry;
- server content retrieval;
- templates;
- images/video/text reuse;
- cards and containers;
- channel renderers;
- action validators;
- action executors;
- AI slots when reasoning text is actually needed.

Target principle:

> Do not spend flagship intelligence to reproduce data already stored on the server.

## 5. Capability System / ORB MAX

Purpose: Orb's self-model of everything it can understand, reveal, potentially execute or orchestrate.

Formula:

```text
ORB MAX
∩ MODE EXECUTION PROFILE
∩ ACTOR ACCESS
∩ ACTOR WILL
∩ CURRENT SESSION
→ AVAILABLE EXECUTION STACK
```

Understanding may see capabilities that are not currently executable.

Current ORB MAX already includes core, knowledge, creation, action, Neo-system and CORP capabilities.

World-scale extension in DEV now includes:
- PROFILE_CREATE;
- MODAL;
- AVATAR;
- SPACE;
- SPACE_3D;
- SPACE_VR;
- METAVERSE;
- WORLD_BUILDER;
- GAME_BUILDER;
- EXPERIENCE_BUILDER;
- SYSTEM_BUILDER.

This allows SYSTEM to show a broad future horizon without pretending the capability is already executable.

## 6. Entity / Relation / Graph System

Purpose: represent what exists in Neo World and how objects relate.

Target objects:
- Actor/profile;
- project;
- work/artifact;
- method;
- service;
- organization;
- place;
- content block;
- site;
- avatar;
- world;
- token/NFT;
- capability;
- session/result/state delta.

Planned graph roles:
- structural relations;
- entity-first SYSTEM retrieval;
- path generation;
- knowledge expansion;
- personal/system graph projections.

## 7. Gestalt / Session / State System

Purpose: represent movement from state A to state B.

Objects:
- semantic session;
- goal;
- check;
- result;
- state delta;
- evidence;
- closure.

Core rule:

> A closed check means a verifiable state change, not a decorative checkbox.

State changes may be produced by:
- completed check;
- transaction;
- artifact creation;
- entity creation;
- activation;
- publication;
- connection;
- external action.

## 8. Action / Economy System

Purpose: safely execute changes in Neo World and connected systems.

Includes:
- offer;
- accept;
- transaction;
- purchase;
- activation;
- payment;
- connector action;
- publishing;
- external ASSIS action.

Server owns truth about:
- price;
- balance;
- ownership;
- permissions;
- dependencies;
- irreversible consequences.

## 9. Mode System

### SYSTEM
Understands discourse through the Neo World frame.

Function:
- enter context;
- understand Actor manifestation;
- show broad horizon;
- reveal possible Neo World path;
- point to relevant capabilities;
- avoid doing prolonged personal/production work for free.

### YNY CHAT
Works directly with content, thought, learning, creativity and personal goals.

### CORP
Turns goals into orchestrated processes, parallel workers and production systems.

Canonical shorthand:

```text
SYSTEM = context + orientation + horizon
YNY CHAT = content work
CORP = processes / production
```

## 10. Guide position in the organism

Guide is not the flagship and not the interface renderer.

Guide:
- gathers context;
- retrieves relevant memory;
- exposes ORB MAX;
- sees access and rights;
- sees sessions/checks/state deltas;
- proposes a scenario/focus;
- supplies relevant server elements.

Then:

```text
GUIDE PACKET
↓
FLAGSHIP UNDERSTANDING
↓
GUIDE / SCENARIO SELECTION
↓
DYNAMIC INTERFACE COMPOSER
↓
SERVER BLOCKS + OPTIONAL AI SLOTS
↓
ORB LANGUAGE
↓
CHANNEL RENDERER
↓
ACTOR ACTION
↓
STATE DELTA
```

## 11. Development status legend

- `working_prod` — live and used in production;
- `working_dev` — implemented/tested in YNY DEV;
- `building` — current implementation target;
- `planned` — architecture established but not yet implemented;
- `concept` — useful horizon, not yet sufficiently specified.

## 12. Skeleton rule

Before adding a feature, determine which organ owns it.

Examples:
- remembering a preference → Memory System;
- understanding why it matters now → Cognitive System / Guide;
- expressing a possible action → Orb Language;
- rendering the button/card → Dynamic Interface System;
- checking whether the action exists → ORB MAX;
- validating price/access → Action/Economy System;
- executing it → executor;
- recording what changed → State System;
- linking the result to Actor/project/world → Entity Graph.

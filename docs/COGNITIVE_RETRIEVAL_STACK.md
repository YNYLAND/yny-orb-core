# COGNITIVE RETRIEVAL STACK

## Why this exists

Guide Packet and Guide Focus are only the orchestration layers. They do not replace memory, vector retrieval or entity graphs. They assemble the relevant pieces of those systems for the flagship Orb.

## Memory / knowledge layers

### L0 — Raw discourse
`conversation_messages`

The primary record of what was actually said. Never replaced by summaries.

### L1 — Semantic summary blocks
`session_summary_blocks`

Periodic semantic compression directly from raw dialogue. Blocks are divided by topic / turn of meaning, not mechanically by message count.

Each block can have an embedding.

Purpose:
- restore older conversational context cheaply;
- detect recurring themes;
- support vector retrieval over old dialogue;
- feed higher-level chronicle / pattern analysis.

Important: summary blocks are NOT semantic `context_sessions` and must remain independent from session closure.

### L2 — Events and durable profile memory
`memory_events` → `profile_memory`

`memory_events` record meaningful events, agreements, goals, decisions, results and state transitions.

`profile_memory` stores durable knowledge about the Actor after distillation. Durable memories can have embeddings.

Direct event mirroring gives immediate continuity; the background memory builder later classifies whether the event is durable, redundant or temporary.

### L3 — Summary of summaries / Profile Chronicle
Planned.

Periodic higher-order synthesis across:
- semantic summary blocks;
- memory events;
- durable profile memory;
- semantic sessions;
- closed checks and results;
- state deltas;
- entities and artifacts.

This layer should preserve epistemic status: observed / confirmed / inferred.

### L4 — Knowledge Blocks / Infoteka
Current legacy store: `knowledge_items`.

The existing table is intentionally simple (`id`, `content`, `embedding`, `created_at`) and already supports vector search, but it is too poor for the future cognitive system.

Infoteka should become the knowledge-block factory:

SOURCE
→ clean noise
→ semantic segmentation
→ normalize
→ attach metadata
→ attach entities / relations
→ embed
→ store reusable blocks

Future knowledge blocks should support at least:
- scope: personal / project / system / public;
- owner profile / project;
- source id / URL / artifact;
- chunk index and content hash;
- title / tags / language;
- entity ids;
- relation ids;
- trust / epistemic status;
- timestamps / freshness;
- embedding.

### L5 — Vector retrieval
Partially available at storage level; not yet wired into Guide.

Current stores with embeddings can include:
- semantic summary blocks;
- profile memory;
- knowledge items / future Infoteka blocks.

Future retrieval pipeline:

CURRENT REQUEST
→ query embedding
→ search personal summaries
→ search profile memory
→ search personal Infoteka
→ search system knowledge
→ deduplicate / rank
→ feed relevant blocks into Guide Packet

Vector retrieval should retrieve meaning, not dump the whole memory.

### L6 — Entity relations / graph
Planned; not yet implemented as a real graph store.

The graph should represent relations between:
- Actor;
- entities / passports;
- projects;
- artifacts;
- sessions;
- checks;
- capabilities;
- places;
- products / offers / transactions;
- knowledge blocks.

Graph expansion complements vector search:
- vector says “this is semantically relevant”;
- graph says “this is structurally connected”.

Both personal and system graphs are expected.

### L7 — Guide Packet
Deterministic state snapshot.

Collects direct discourse, summaries, agreements, memory, sessions/checks, state deltas, access and ORB MAX.

### L8 — Guide Retrieval (next)
Planned bridge that performs vector + graph retrieval before final packet assembly.

### L9 — Guide Focus
Ranks what matters now:
- current Actor state;
- target state;
- point of interest;
- current open check;
- relevant ORB MAX;
- possible next state delta;
- progressive disclosure / offer gate.

## Canonical pipeline

RAW DISCOURSE
→ SUMMARY / MEMORY / INFOTEKA
→ VECTOR + GRAPH RETRIEVAL
→ GUIDE PACKET
→ GUIDE FOCUS
→ FLAGSHIP ORB
→ RESPONSE / ACTION
→ MEMORY EVENT / STATE DELTA

The retrieval layers provide evidence and context. Guide organizes it. The flagship Orb remains the intelligence that understands and responds.

# ORB INFORMATION SYSTEM

## Purpose

Information System maintains the informational field Orb can access, trust, retrieve and use for reasoning, verification and contextual work.

It is distinct from:
- Memory System — continuity of Actor/Orb relationship;
- Connector System — technical access to external sources/services;
- Integration System — progressive inclusion into the unified Neo World field;
- INFOTEKA — a specific module/product that can inspect and decompose raw information into reusable containers.

## Core question

> What information can Orb know, retrieve, compare, verify and use right now, and what source/status does that information have?

## Information classes

- canonical Neo World knowledge;
- Wiki/entity information;
- `knowledge_items`;
- trusted source-of-truth datasets;
- documents and structured reference materials;
- Actor-authorized personal sources;
- connected Telegram/ChatGPT/social/account sources;
- feeds/news/external data streams;
- imported content;
- private profile information sources;
- information produced by INFOTEKA and other processing modules;
- automatically generated information memory/knowledge blocks.

## Source scopes

Information should eventually carry an explicit scope such as:
- system;
- public;
- profile_private;
- profile_shared;
- project;
- team/corp;
- session/transient;
- external_live.

A source can be useful to a personal Orb without ever becoming shared/integrated.

## Target information pipeline

```text
SOURCE
↓
ACQUIRE / RECEIVE
↓
OPTIONAL CLEAN / NORMALIZE
↓
SEMANTIC BLOCKS / CONTAINERS
↓
METADATA / PROVENANCE / SCOPE / VERSION / TRUST
↓
EMBEDDING / INDEX
↓
RETRIEVAL
↓
GUIDE / FLAGSHIP ORB
```

## Responsibilities

- source registry;
- source trust / truth level;
- semantic blocks;
- chunk size / structure standards;
- metadata and tags;
- personal/system/public scopes;
- embeddings;
- vector indexes;
- freshness/versioning;
- provenance;
- retrieval APIs;
- automatic information builders;
- dedupe / supersession;
- relevance filtering;
- source preference per Actor/project/mode.

## Current embryo

- `knowledge_items`;
- embeddings;
- vector matching;
- system knowledge retrieval in current Orb API.

Current `knowledge_items` are intentionally recognized as an early structure. Future blocks should be easier to retrieve, attribute, version, scope and combine.

## Future knowledge block fields

Possible fields:
- block_id;
- source_id;
- source_type;
- title;
- content;
- semantic_type;
- scope;
- owner/profile/project;
- entity_keys;
- relation_seeds;
- tags;
- trust_level;
- freshness;
- version;
- embedding;
- active/status.

## Relationship with Connector System

Connector System can make an external source readable by Orb.

Example:

```text
Actor connects Telegram channel
↓
Connector grants controlled read access
↓
Information System treats it as an Actor-specific source
↓
Guide retrieves relevant blocks when useful
```

No shared Neo World integration is required.

## Relationship with INFOTEKA

INFOTEKA is a universal decomposition/packaging module.

It may take raw information and separate it into useful containers, similar to dismantling raw material into parts for different uses:

```text
RAW MATERIAL
↓
INFOTEKA
├─ semantic knowledge block
├─ entity candidate
├─ relation candidate
├─ artifact/media component
├─ page/site content block
├─ social-post candidate
├─ memory candidate
└─ noise/cache/irrelevant fragment → discard
```

Those containers can then be consumed by multiple systems:
- Information System;
- Integration System;
- Memory System;
- Dynamic Interface System;
- Page/Site generators;
- SMM/content pipelines;
- Entity/Graph System.

The platform may use similar internal processing automatically. INFOTEKA as a user module remains optional.

## Relationship with Integration System

Information can remain private, temporary, project-local or source-only.

Integration is a separate progressive transition that determines whether selected information/containers become visible or reusable parts of the unified Neo World field and under what rights.

## Relationship with Guide

Guide should retrieve only relevant informational blocks instead of loading the entire field.

Future retrieval may combine:
- vector similarity;
- source trust;
- freshness;
- Actor preferences;
- mode policy;
- graph relations;
- current semantic session.

## Canonical rules

> Information System is the informational field Orb can know and retrieve.

> Connector System determines what external sources Orb can access.

> Integration System determines how selected manifestations become part of the unified field.

# ORB INFORMATION SYSTEM

## Purpose

Information System maintains the informational field Orb can use for retrieval, verification, reasoning and contextual work.

It is distinct from:
- Memory System — continuity of Actor/Orb relationship;
- Integration System — admission into the unified Neo World field;
- INFOTEKA — a specific module/product that may feed or structure information.

## Core question

> What information can Orb access, trust, retrieve and use right now?

## Information classes

- canonical Neo World knowledge
- Wiki/entity information
- `knowledge_items`
- documents
- source-of-truth datasets
- actor-authorized personal information sources
- connected feeds
- news / external data streams
- imported structured content
- information produced by INFOTEKA and other modules

## Pipeline

```text
SOURCE
↓
ACQUIRE / RECEIVE
↓
CLEAN / NORMALIZE
↓
SEMANTIC CHUNKING
↓
METADATA / PROVENANCE / SCOPE / VERSION
↓
EMBEDDING / INDEX
↓
RETRIEVAL
↓
GUIDE / FLAGSHIP ORB
```

## Responsibilities

- source registry
- source trust / truth level
- semantic blocks
- chunk size / structure standards
- metadata and tags
- personal/system/public scopes
- embeddings
- vector indexes
- freshness/versioning
- provenance
- retrieval APIs
- auto-builders for information memory
- dedupe / supersession

## Current embryo

- `knowledge_items`
- embeddings
- vector matching

## Future structure

Knowledge blocks should become easier to retrieve and combine than current plain `knowledge_items`.

Possible fields:
- block_id
- source_id
- source_type
- title
- content
- semantic_type
- scope
- owner/profile
- entity_keys
- relation_seeds
- tags
- trust_level
- freshness
- version
- embedding
- active/status

## Relationship with Connector System

Connector System can provide live or imported external data to Information System.

## Relationship with Integration System

Information may remain private, temporary or source-only.

Only selected candidates that pass Integration System become canonical shared Neo World objects/relations/content.

## Relationship with Guide

Guide retrieves only the relevant informational blocks for the current request instead of loading the entire information field.

## Canonical rule

> Information System is what Orb can know and retrieve; Integration System is what becomes part of the shared whole.

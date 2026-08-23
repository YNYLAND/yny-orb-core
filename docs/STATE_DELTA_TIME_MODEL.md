# STATE DELTA / YNY TIME MODEL

Version: 0.1.0
Status: canonical draft

## Core idea

YNY LAND can treat meaningful state change as its fundamental unit of motion.

A closed check is not merely a completed to-do item. It is evidence that the Actor and/or the system moved from one measurable state to another.

Examples:
- no book -> book exists;
- no entity passport -> entity passport exists;
- capability locked -> capability activated;
- payment pending -> transaction confirmed;
- project idea -> project created;
- unpublished -> published.

## State delta

A State Delta describes a transition:

BEFORE -> ACTION / EVENT -> AFTER

It may affect:
- Actor state;
- system state;
- both simultaneously.

Suggested canonical shape:
- actor_before
- actor_after
- system_before
- system_after
- delta_type
- source
- evidence
- measurable_delta
- confidence
- timestamp
- linked_context_session_id
- linked_check_id
- linked_transaction_id
- linked_entity_id
- linked_artifact_id

## Delta classes

Initial classes:
- TRANSACTION_DELTA
- ARTIFACT_DELTA
- ENTITY_DELTA
- CAPABILITY_DELTA
- PROJECT_DELTA
- KNOWLEDGE_DELTA
- WORLD_DELTA
- ACTOR_DELTA

Checks are one mechanism that may certify a State Delta, but they are not the only mechanism.

A transaction can certify its own delta because the database contains machine-verifiable evidence.
An artifact creation can certify its own delta when the artifact exists.
A publication delta can certify itself when the destination confirms publication.
A semantic check may require stronger semantic or human evidence.

## YNY time

Physical time remains useful as chronology, but the meaningful internal history of YNY LAND can be read as a river of state transitions.

System time answers: WHEN did something happen?
State-delta time answers: WHAT became different?

A useful conceptual model:

SYSTEM(t0) -- delta_1 --> SYSTEM(t1) -- delta_2 --> SYSTEM(t2)

Each accepted delta is an iteration of the living system.

This means the history of an Actor can be represented not only as messages and timestamps, but as a sequence of material state changes:

Actor before -> delta -> Actor after
System before -> delta -> System after

## Why this matters

This gives YNY LAND a measurable answer to questions such as:
- What actually changed because of this interaction?
- What did the Actor gain, create, activate, publish, learn, buy or complete?
- Which changes affected only the Actor, only the system, or both?
- Which events are machine-verifiable and which depend on semantic evidence?
- How did an Actor move through Neo World over time?

It also gives Orb a better success metric than message count or conversation length.

A valuable Orb interaction should tend to produce meaningful state change while respecting Actor will.

## Relation to checks

CHECK is not the top-level ontology object.

STATE CHANGE
  -> check completion
  -> transaction
  -> artifact creation
  -> entity creation
  -> activation
  -> publication
  -> external action

A completed check is therefore one certified form of State Delta.

## Open design question

Later we should decide whether State Delta becomes:
1. its own append-only event table;
2. a normalized projection over memory_events, transactions, artifacts and checks;
3. both: immutable raw events + derived canonical deltas.

Current recommendation: preserve raw source events and derive canonical State Deltas with evidence links.

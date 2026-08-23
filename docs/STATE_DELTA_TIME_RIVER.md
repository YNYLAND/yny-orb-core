# STATE DELTA / YNY LAND TIME RIVER

## Core idea

YNY LAND can treat meaningful change of state as a primitive unit of movement.

Time in the system is not only wall-clock time. It is also the ordered sequence of meaningful state transitions.

Canonical image:

> The river of time in YNY LAND is the flow of state changes.

A state change may happen to the Actor, to Neo World, or to both at once.

## State Delta

A State Delta is a verified transition from BEFORE to AFTER.

Minimal structure:

- actor_before
- actor_after
- system_before
- system_after
- delta_type
- evidence
- source
- timestamp
- related_session
- related_check
- related_entities
- related_transaction

## Examples

### Artifact Delta

BEFORE:
Actor has no book.

AFTER:
Actor has a book.
Neo World contains a new book artifact.

Both the Actor and the system changed state.

### Transaction Delta

BEFORE:
Actor has X balance and no purchased capability.

AFTER:
Balances changed.
Transaction is recorded.
Capability or asset is owned.

The transaction itself can verify and close the delta without model judgment.

### Capability Delta

WEB locked
→ WEB activated

### Entity Delta

No entity passport
→ passport exists

### Publication Delta

Draft exists privately
→ publication exists in a public channel

### Project Delta

Idea only
→ project exists with identity, assets and next actions

### Knowledge Delta

Question unresolved
→ research result exists and is attached to context

### Actor Delta

No defined role
→ Actor has a selected and manifested role

No first client
→ first client interaction/transaction exists

## Checks are one verification mechanism, not the whole ontology

A closed check is one way to certify a State Delta.

Other mechanisms can certify state automatically:
- payment transaction;
- database insert/update;
- mint;
- deploy;
- publish;
- connector action;
- external webhook/result;
- artifact creation.

Therefore:

STATE CHANGE
├── check completion
├── transaction
├── artifact creation
├── entity creation
├── activation
├── publication
├── external action
└── other verified transition

## Closed check

A check is not complete because someone clicked a checkbox.

A check is complete when its required result exists and the system can point to evidence.

Canonical rule:

> Closed check = achieved state.

This allows checks to represent real progress rather than task-list theatre.

## The Actor and the world can change simultaneously

Many important deltas have two sides.

Example: create a book.

Actor Delta:
"I do not have my book"
→
"I have my book"

System Delta:
"BOOK entity/artifact does not exist"
→
"BOOK entity/artifact exists and is linked to Actor"

This dual change is especially important for Neo World because manifestation is both personal and systemic.

## State River

The Actor's path can be represented as an ordered chain:

STATE 0
→ Δ1
→ STATE 1
→ Δ2
→ STATE 2
→ Δ3
→ STATE 3

This chain can become:
- personal history;
- project history;
- Neo World history;
- achievement graph;
- system analytics;
- context for Orb;
- a visible interface stream.

## River of Good News

A user-facing projection of the State River can surface positive, meaningful transitions instead of noise.

Examples:
- profile created;
- first capability activated;
- book completed;
- passport manifested;
- first publication released;
- first client arrived;
- first transaction completed;
- project moved from idea to active;
- important blocked check was closed.

This can be shown on main screens as a living stream of what has actually changed.

The stream should not be limited to celebratory copy. Every item should be backed by a State Delta with evidence.

## Why this matters for Orb

Orb should not measure success primarily by number of messages or length of conversation.

Orb should understand:
- what state the Actor was in;
- what target state matters;
- what changed;
- what remains open;
- what capability can close the next relevant delta.

This creates a cognition loop:

DISCOURSE
→ CONTEXT
→ CURRENT STATE
→ TARGET STATE
→ GAP
→ NEXT POSSIBLE ACT
→ RESULT
→ VERIFIED STATE DELTA
→ MEMORY / HISTORY

## Relation to semantic sessions

A semantic session is a temporary container around a desired state transition or group of related transitions.

Checks represent expected intermediate results.

State Deltas are the verified facts of movement.

A session may close when its required deltas exist.

Optional future deltas should not keep the original session artificially open; they can create child sessions or new potentials.

## Relation to transactions

Transactions are especially strong State Deltas because their evidence is deterministic.

They can often close themselves:

payment confirmed
→ ledger updated
→ balances updated
→ ownership/access updated
→ delta recorded

No language model interpretation is required to prove the state change.

## Relation to time

Wall-clock time answers:

> When did something happen?

State time answers:

> What changed between one meaningful state of the world and the next?

YNY LAND can use both.

This gives the system a form of internal chronology based on manifestation rather than mere elapsed seconds.

## Canonical summary

> YNY LAND lives through changes of state.

> A State Delta is the smallest meaningful proof that the Actor or the world is no longer in the same state as before.

> The ordered sequence of these deltas forms the River of Time.

> A user-facing positive projection of this river can become the River of Good News.

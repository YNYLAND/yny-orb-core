# ORB MEMORY BUS v1

## Purpose

Orb memory is not a passive archive. It is a system layer that lets meaningful changes in discourse become usable context on the next interaction and, when appropriate, durable profile knowledge.

The memory bus separates immediate memory from later distillation.

## Canonical flow

```text
conversation
   ↓
Orb detects a meaningful event
   ↓
memory_event
   ↓ immediately, without another model call
profile_memory: memory_event_direct
   ↓
available to Orb on the next turn
   ↓ background librarian
DURABLE MEMORY or explicit DISCARD/REDUNDANT
```

In parallel:

```text
conversation_messages
   ↓ hourly / batch
memory-summary-builder
   ↓
session_summary_blocks + embedding
```

The direct event mirror gives Orb continuity immediately. The background librarian improves quality later.

## Why immediate memory matters

A meaningful event has already passed one semantic filter: Orb decided that it was worth emitting a MEMORY event. Requiring a second model call before Orb can remember it creates unnecessary delay, cost and failure points.

Therefore a profiled memory event with a non-empty summary is mirrored immediately into profile_memory.

Initial source type:

`memory_event_direct`

This record is active and readable by Orb immediately.

## Durable memory librarian

`profile-memory-builder` processes pending memory_events oldest first.

For each event it must explicitly decide one of two outcomes:

1. DURABLE MEMORY — keep/refine the memory and embed it.
2. DISCARD / REDUNDANT — deactivate the direct mirror because the event is transient or already represented by durable memory.

If the builder fails to classify an event, the direct memory is preserved and the event remains pending for retry. Silence from the classifier must never erase memory.

Processed lifecycle fields on memory_events:

- durable_memory_processed_at
- durable_memory_count
- durable_memory_last_error

## Agreements with Orb

Explicit agreements are first-class durable memory candidates.

Examples:

- “Не предлагай карточки модулей, пока я явно не заинтересуюсь.”
- “Когда я говорю «Погнали», начинай согласованный сценарий.”
- “Не делай так больше.”
- “Всегда сначала показывай короткую версию.”

Orb should treat explicit standing instructions, negotiated conventions and behavioral agreements as durable until the Actor changes or revokes them.

This creates a practical contract layer between Actor and Orb:

```text
agreement
→ memory_event
→ immediate working memory
→ durable agreement
→ behavior respects it
→ later renegotiation changes the state
```

An agreement is not immutable truth. The Actor can revise it. The latest confirmed agreement should supersede conflicting older ones.

## Summary memory

`memory-summary-builder` compresses raw conversation_messages into semantic blocks. It is deliberately independent of semantic context_sessions.

A summary block represents a topic, turn or coherent meaning, not a fixed number of messages.

Each new block receives its embedding during creation. A separate unauthenticated embedding webhook is not required.

Summary blocks preserve latent discourse and enable later retrieval, pattern analysis and profile chronicle generation.

## Security

Background memory workers use a custom internal secret stored in Supabase Vault under:

`orb_memory_internal_secret`

The secret is generated inside the database and is not stored in Git.

Workers may have platform `verify_jwt=false`, but they reject requests unless the `x-orb-memory-secret` header matches the Vault value through `verify_orb_memory_secret`.

The SQL verification function is executable only by `service_role`.

Cron reads the secret from Vault at runtime. No plaintext secret is embedded in cron commands.

## Cost principle

Immediate memory should not require a new model call.

Model calls are reserved for useful compression and distillation:

- semantic conversation summaries;
- durable-memory classification/refinement;
- later profile chronicle synthesis.

This keeps continuity cheap while preserving higher-quality long-term memory.

## Relationship to Guide Core

The memory bus produces ingredients for Guide Core. Guide should later select only relevant memory for the current session instead of dumping all profile memory into every prompt.

Target flow:

```text
recent discourse
+ relevant summary blocks
+ durable profile memory
+ explicit agreements
+ context sessions / checks
+ ORB MAX
→ GUIDE PACKET
→ flagship Orb
```

## Core invariant

> If Orb and the Actor explicitly agreed on something important, the system must not rely on conversational luck to remember it.

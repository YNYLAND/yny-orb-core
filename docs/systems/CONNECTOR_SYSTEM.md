# ORB CONNECTOR SYSTEM

## Purpose

Connector System provides the two-way technical and authorization bridge between Orb and external services, accounts, applications, channels and sources of truth.

Canonical direction:

```text
ORB ⇄ CONNECTOR SYSTEM ⇄ EXTERNAL WORLD
```

Connector means controlled connection, not integration into the shared Neo World field.

## Core question

> What external source or service may this Actor's Orb safely read from, write to, or act through?

## Responsibilities

- connector registry;
- provider adapters;
- OAuth/API keys/tokens/secrets;
- Actor consent and revocation;
- external account identity mapping;
- read scopes;
- write/action scopes;
- webhooks/subscriptions;
- external API requests;
- provider response/error normalization;
- connection health;
- rate limits / quotas;
- audit/logging;
- personal source-of-truth connections.

## Examples

- Orb plugin in ChatGPT;
- importing authorized ChatGPT history into profile memory;
- connecting Telegram account/channel as a personal source of truth;
- Instagram / Facebook / TikTok / YouTube;
- email / messengers;
- calendar;
- maps / GEO providers;
- payment/bank providers;
- GitHub / Supabase / Cloudflare;
- external APIs;
- Unity / mobile / external apps;
- publication destinations for SMM AUTOPILOT.

## Two-way flow

### Inbound

```text
EXTERNAL SERVICE
→ CONNECTOR
→ authorized data/event
→ personal Information / Memory / current context
→ optional further processing / Integration
```

Example:

```text
Actor connects a Telegram channel
↓
Orb is allowed to read it as a source of truth for this Actor
↓
Guide may retrieve relevant material from it
↓
material can remain private forever
```

### Outbound

```text
ORB / ACTION SYSTEM
→ CONNECTOR
→ external service
→ normalized result
→ STATE DELTA / MEMORY / LOG
```

Examples:
- publish content to TikTok/Instagram/YouTube;
- send a message;
- create a calendar event;
- call an external API;
- deploy a site;
- execute an authorized provider action.

## Connector vs Integration

A Connector may repeatedly read or write without integrating anything into the common Neo World field.

```text
CONNECTED ≠ INTEGRATED
```

Example:

```text
Telegram connected
→ Orb reads authorized messages
→ selected facts may inform private profile memory
→ optional INFOTEKA processing
→ optional Integration System transition
→ only then may selected structures become part of a graph/shared field under defined visibility and rights
```

## Connector as a user-facing platform system

Connector System is not only backend plumbing. It is already conceptually present in the cabinet/top information menu so Actors can manage what their Orb is connected to.

Potential user-facing categories:
- READ SOURCES — what Orb may read;
- WRITE DESTINATIONS — where Orb may publish/send;
- PERSONAL TRUTH SOURCES — channels/docs/accounts treated as trusted Actor-specific inputs;
- AUTOMATION CONNECTIONS — services used by SMM AUTOPILOT / ASSIS / CORP;
- ORB PORTABILITY — connections that bring data from another AI/service into profile memory.

## Relationship with Information System

Connector supplies live or imported source material to Information System.

The source can remain personal/private and does not need to pass Integration System.

## Relationship with Memory System

Authorized external history can become profile memory when appropriate, especially for continuity across external AI/tools/accounts.

## Relationship with ORB MAX

Capabilities such as CONNECT, SMM_AUTOPILOT, MESSAGING, BOOKING, GEO, ASSIS, external publishing and source ingestion may depend on Connector System.

## Canonical rules

> Connector means controlled two-way connection.

> A connected source may become part of a personal Orb's truth/context without becoming part of the shared Neo World field.

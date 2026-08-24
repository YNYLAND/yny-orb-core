# ORB CONNECTOR SYSTEM

## Purpose

Connector System provides the two-way technical and authorization bridge between Orb and external services, accounts, applications and channels.

Canonical direction:

```text
ORB ⇄ CONNECTOR SYSTEM ⇄ EXTERNAL WORLD
```

It does not decide that imported data becomes part of the shared Neo World graph. That is Integration System.

## Core question

> How can Orb safely read from or act through this external system on behalf of the Actor?

## Responsibilities

- connector registry
- provider adapters
- OAuth/API keys/tokens/secrets
- actor consent and revocation
- external account identity mapping
- read scopes
- write/action scopes
- webhooks/subscriptions
- external API requests
- normalization of provider responses/errors
- connection health
- rate limits / quotas
- audit/logging

## Examples

- ChatGPT plugin / Orb plugin
- importing authorized ChatGPT history into profile memory
- Telegram account/channel connection
- Instagram / Facebook / TikTok / YouTube
- email / messengers
- calendar
- maps / GEO providers
- payment/bank providers
- GitHub / Supabase / Cloudflare
- external APIs
- Unity / mobile / external apps

## Two-way flow

### Inbound

```text
EXTERNAL SERVICE
→ CONNECTOR
→ authorized data/event
→ Information / Memory / Cognitive / Integration candidate
```

### Outbound

```text
ORB / ACTION SYSTEM
→ CONNECTOR
→ external service
→ normalized result
→ STATE DELTA / MEMORY / LOG
```

## Important distinction

A Connector may read a source repeatedly without integrating any of its data into the shared Neo World field.

Example:

```text
Telegram connected
→ Orb may read authorized messages
→ selected information may enter personal memory
→ only explicitly integrated candidates pass Integration System
→ then become shared Neo World entities/content/relations
```

## Relationship with ORB MAX

Capabilities such as CONNECT, SMM_AUTOPILOT, MESSAGING, BOOKING, GEO, ASSIS and external publishing may depend on Connector System.

## Canonical rule

> Connector means controlled connection, not membership in the whole.

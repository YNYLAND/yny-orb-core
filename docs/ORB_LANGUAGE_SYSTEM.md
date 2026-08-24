# ORB LANGUAGE SYSTEM

## Purpose

Orb Language System is the channel-independent semantic language through which Orb expresses meaning, state, possible actions and results.

It is not a renderer and it is not the visual interface itself.

Canonical principle:

> Stable meaning, living expression.

A semantic action may stay constant while its visible label adapts to language, tone, relationship and current conversational context.

Example:

```text
ACTION = OPEN_CABINET

Possible labels:
- Открыть кабинет
- Войти в кабинет
- Перейти в свой кабинет
- Welcome в твой space
```

The semantic action does not change.

## Current production pattern

The live Telegram implementation already contains the embryo of this language:

```text
conversation / system context
→ semantic action
→ UI button
→ Actor acceptance/click
→ executor
→ changed system state
```

Known live semantic actions include:
- `create_profile`
- `open_cabinet`
- `open_skill_catalog`
- `open_skill`
- `purchase_skill`
- `enter_ynychat`
- `exit_ynychat`
- `toggle_mode`
- `get_mode_state`
- `get_list_state`
- `purchase_list_slots`
- Orb Web handoff / continuation.

The Telegram renderer already accepts `btn.label` with a fallback, and the legacy profile flow translates button text through GPT. This proves that action semantics and surface wording can be separated.

Current limitation: `orb-api` v12 sanitizes model-proposed skill/mode labels into fixed server labels, while Telegram profile/open-profile wording remains more dynamic. The target architecture should preserve semantic safety while restoring living wording where appropriate.

## Acceptance as execution

In Orb Language, acceptance is not a decorative confirmation state.

For a reversible or clearly requested action:

```text
OFFER / PROPOSAL
→ ACCEPT
→ ACTION EXECUTION
→ STATE DELTA
```

If the Actor explicitly says `создай профиль`, the natural-language command already contains acceptance and the action may execute directly.

If Orb merely suggests creating a profile, the button click is the ACCEPT event.

## Language primitives

### Meaning / content
- `TEXT`
- `QUOTE`
- `KNOWLEDGE_BLOCK`
- `MEDIA`
- `ARTIFACT`
- `RESULT`

### Identity / world objects
- `PROFILE`
- `AVATAR`
- `ENTITY`
- `PAGE`
- `MODAL`
- `SPACE`
- `WORLD`
- `GAME`
- `PORTAL`

### Structure / navigation
- `BUTTON`
- `BUTTON_ROW`
- `CARD`
- `MENU`
- `LIST`
- `TREE`
- `WAY`
- `MAP`

### Process / state
- `SESSION`
- `CHECK`
- `CHECKLIST`
- `STATUS`
- `PROGRESS`
- `STATE_DELTA`

### Action / economy
- `ACTION`
- `POTENTIAL_ACTION`
- `HANDOFF`
- `CONNECT`
- `OFFER`
- `ACCEPT`
- `ACTIVATION`
- `TRANSACTION`

## Label policy

Every actionable language element should define a label policy.

### `dynamic`
Used for safe navigation and conversational actions.

The wording may be generated/adapted to:
- Actor language;
- tone;
- current discourse;
- relationship style;
- surrounding sentence.

Examples: `OPEN_CABINET`, `OPEN_PAGE`, `ENTER_YNYCHAT`, `CONTINUE`.

### `guided_dynamic`
Orb may vary wording inside a constrained intent.

Example:

```text
intent: invite Actor to create profile
fallback: Создать профиль
forbidden meanings: purchase / irreversible consent / unrelated action
```

### `canonical`
Used where wording must not obscure consequences.

Examples:
- financial acceptance;
- purchase;
- transfer;
- mint;
- destructive action;
- irreversible legal/state change.

## Model role

The flagship model may:
- identify which semantic expression is useful;
- suggest an action intent;
- produce contextual text for a safe language slot;
- formulate a dynamic label within the allowed intent.

The flagship model must not own:
- price truth;
- ownership truth;
- permissions;
- account state;
- executor selection;
- transaction execution;
- irreversible confirmation rules.

## Relationship with Guide

Guide does not draw the UI.

Guide exposes available/relevant language elements to Orb and/or Dynamic Interface System.

Conceptually:

```text
GUIDE PACKET
+ GUIDE FOCUS
+ ORB MAX
+ ACTOR ACCESS
+ SERVER CONTENT
↓
ORB LANGUAGE ELEMENTS
```

The language is the vocabulary. Guide decides what vocabulary is relevant. The flagship decides meaning/interpretation where reasoning is required. The Interface System renders and executes.

## Core rule

> Orb does not speak Telegram, Web or Unity. Orb speaks Orb Language.

Channel adapters translate Orb Language into their native interface form.

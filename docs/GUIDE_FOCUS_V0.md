# GUIDE FOCUS v0.2

## Purpose

Guide Focus is not a second Orb. It is a deterministic attention selector over the Guide Packet and ORB MAX.

It answers:

> What deserves the flagship Orb's attention right now?

## Progressive disclosure canon

SYSTEM unfolds a request in this order:

1. HORIZON — show what is broadly possible and why the current context may matter later.
2. CURRENT INTEREST — identify what the Actor is actually focused on now.
3. RELEVANT CAPABILITY — explain the specific capability only when it is relevant to the current gap.
4. OFFER IF INTEREST — render card / price / activation only after explicit Actor interest.

This is a SYSTEM standard, not a personal agreement.

Canonical rule:

> SYSTEM may be generous with perspective and restrained with offers.

## ORB MAX visibility

SYSTEM cognition can see every non-deprecated ORB MAX capability, even when it is not currently executable.

`mode_available`, actor access, required skills and connectors gate execution — not understanding.

This allows SYSTEM to describe a future route without pretending the capability is already active.

## Focus sources

Guide Focus may focus from:
- explicit capability mention in the current message;
- current actionable / blocked / potential required check;
- active semantic session goal;
- current message when no session exists.

An explicit current interest may override an older open check for conversational attention, while the open check remains part of the session state.

## Offer gate

Offer rendering is allowed only when:
- the current mode policy allows it;
- explicit Actor interest is detected / confirmed;
- a concrete capability is identified.

Price never leads the interaction.

## State transition

Focus keeps the current session's `current_state`, `target_state`, and nearest open check visible so the flagship Orb can reason toward a meaningful state delta rather than merely continue conversation.

## Retrieval status

v0.2 intentionally exposes which cognition layers are active:
- direct recent discourse: yes;
- direct semantic summaries: yes;
- direct profile memory: yes;
- vector similarity retrieval: not yet;
- knowledge-item retrieval: not yet;
- graph / relation expansion: not yet.

This makes missing cognitive infrastructure explicit rather than pretending it already exists.

## Acceptance tests

### No commercial interest
Actor: “I want to understand how my material can become a manifestation path. What is possible here?”

Expected:
- show horizon;
- focus on current semantic check / gap;
- identify relevant ORB MAX;
- `offer_card_allowed = false`.

### Explicit capability interest
Actor: “I am interested in SMM AUTOPILOT. Show how to connect it and what it costs.”

Expected:
- point of interest becomes `SMM_AUTOPILOT`;
- capability may be explained even if not mode-executable yet;
- `offer_card_allowed = true`;
- actor access / activation status still gates execution.

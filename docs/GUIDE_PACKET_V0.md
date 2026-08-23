# GUIDE PACKET v0

## Purpose

Guide is not a second intelligence. Guide is a deterministic context assembler that prepares the working state for the flagship Orb before cognition and response generation.

Guide answers a pre-cognitive question:

> What is happening now, what agreements apply, what is already known, what is unfinished, what has changed, what can Orb potentially do, and what may the Actor actually execute?

## Packet layers

1. MODE FRAME
   - purpose
   - frame
   - success metric
   - retrieval policy
   - capability policy
   - agent policy
   - offer policy

2. RECENT DISCOURSE
   - latest messages in the current conversation session

3. SEMANTIC SUMMARY
   - recent summary blocks for the current conversation session

4. ACTIVE AGREEMENTS
   - explicit agreements, preferences, decisions and workflow rules that should influence current behavior

5. PROFILE MEMORY
   - durable user context not duplicated in active agreements

6. CONTEXT SESSIONS + CHECKS
   - active / blocked / paused semantic sessions
   - current state
   - target state
   - open and completed checks
   - capability keys associated with checks

7. RECENT EVENTS + STATE DELTAS
   - recent memory events
   - measurable or meaningful changes of state

8. ACTOR ACCESS
   - activated skills / execution rights

9. ORB MAX CANDIDATES
   - relevant core and mode-available capabilities
   - execution profile
   - provider strategy
   - whether multi-agent execution is allowed

## Canonical rules carried in the packet

- discourse is a sensor;
- context comes before capability;
- understand before handoff;
- show horizon before offer;
- offer requires Actor interest;
- the cognitive target is meaningful state change.

## Important distinction

Guide Packet v0 DOES NOT choose the answer and DOES NOT generate advice.

It is an inspectable state snapshot. The next layer, Guide Focus, will rank what deserves attention now.

Pipeline:

DISCOURSE
→ GUIDE PACKET
→ GUIDE FOCUS
→ FLAGSHIP ORB COGNITION
→ RESPONSE / ACTION
→ MEMORY EVENT / STATE DELTA

## Test principle

A Guide Packet is good when a human can inspect it and understand why Orb should behave in a certain way without relying on hidden intuition.

Example:

If active_agreements contains "do not show module cards until explicit interest", offer_policy says offer_only_after_interest=true, the active session is about author manifestation, and the current actionable check is "build manifestation path", then SYSTEM may describe future capabilities but must not render a purchase card.

## Security

`build_orb_guide_packet` is service-only. PUBLIC, anon and authenticated execution are revoked. It is intended to be called by trusted Orb backend code, not directly by clients.

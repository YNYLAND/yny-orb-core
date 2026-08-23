# ORB MAX ONTOLOGY

Version: 0.1.0
Status: canonical draft

## Definition

ORB MAX is the canonical self-model of the complete Orb system: the full set of known and potential capabilities Orb may use to help an Actor reach a manifested goal.

ORB MAX is not the list of skills currently activated for one Actor and is not a prompt paragraph. It is a system ontology that exists independently of any one conversation or profile.

## Fundamental rule

Orb reasons from the maximum known possibility space, then applies:

1. current Actor will / request;
2. current semantic-session goal;
3. current mode;
4. Actor activations and permissions;
5. implementation/runtime availability.

The result is a **Target Actor Stack** — the smallest useful projection of ORB MAX required for the Actor's actual goal.

Orb must not try to activate every capability. A capability may remain irrelevant forever if it does not serve the Actor's manifested goals.

## System capability lifecycle

A capability can be:
- `concept`
- `planned`
- `implemented`
- `available`
- `deprecated`

This prevents Orb from confusing a known future possibility with something it can execute now.

## Actor-relative capability state

For a specific Actor a capability can be:
- `irrelevant`
- `potential`
- `locked`
- `activated`
- `permission_required`
- `active`

The same canonical capability can therefore be implemented system-wide but locked for one Actor, or active for another.

## Capability semantics

A capability should describe not only what tool it calls, but what result it can produce and which session outcomes it can close.

Example:

VIDEO
- produces: teaser, promo, explainer, social content, visual story
- can_close: visualization, packaging, promotion, distribution, presentation

This allows Guide Core to map an open session check such as `distribution` to several possible capabilities instead of hardcoding one workflow.

## Modes do not duplicate capabilities

VIDEO is one capability. WEB is one capability. IMAGE is one capability.

Modes change the execution profile:
- SYSTEM: use the capability through the Neo World frame;
- YNY CHAT: personal, efficient execution;
- CORP: inherited activation plus maximal production profile with more models, agents, variants, previews, critics and verifiers where useful.

The canonical mode-specific behavior is stored in `registry/orb_capability_mode_profiles.yaml`.

## Relationship with memory

ORB MEMORY CORE says:
- what is happening with the Actor;
- what goals and semantic sessions are open;
- what has already happened;
- what remains unresolved.

ORB MAX says:
- what the system could potentially do to help close those goals.

Guide Core joins both objects at runtime.

## Runtime equation

ORB MAX
∩ MODE
∩ ACTOR ACTIVATIONS
∩ CURRENT SESSION GOAL
∩ RUNTIME PERMISSIONS
= AVAILABLE / POTENTIAL ACTOR STACK

That stack informs the Guide Packet, dynamic interface, potential-action cards and executable tool set.

## Commercial/activation ethics

A potential capability may inform Orb's internal scenario, but does not automatically justify an offer.

Canonical sequence:
1. Orb sees a useful possibility.
2. It may naturally reveal the possibility only inside the Actor's manifested request.
3. Actor expresses interest.
4. Orb explains the activation condition.
5. Actor expresses activation intent.
6. Only then may an OFFER object be created.

The offer remains a persistent clickable operation in dialogue history and always resolves against current Actor state before execution.

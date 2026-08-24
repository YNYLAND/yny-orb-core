# ORB INTEGRATION SYSTEM

## Purpose

Integration System governs the progressive inclusion of an Actor, resource, need, project, artifact, knowledge block, content object or other manifestation into the unified Neo World field.

It is not transport, not a Connector, and not a binary accepted/rejected gate.

Canonical idea:

> Integration means becoming progressively more legible, connected, reusable and participatory inside the whole.

An Actor may use YNY CHAT without integrating anything into the shared Neo World field. Integration is voluntary and progressive.

## First executable contour: PLUS / MINUS

The first practical Integration contour is the existing Actor resource/need model:

```text
PLUS  = what I have / what is in surplus / what I can share
MINUS = what I need / what is missing / what I am looking for
```

This is not an allow/deny list.

It is the simplest way for an Actor to expose selected parts of their state to the unified field so Orb can perform real matching.

```text
ACTOR A PLUS
      ↕
   ORB MATCH
      ↕
ACTOR B MINUS
```

Potential outcomes:
- useful contact;
- exchange;
- collaboration;
- project;
- service;
- product offer;
- transaction;
- delivery/fulfilment;
- new entity/relation;
- new semantic session;
- measurable State Delta.

This first contour already has an interface concept in SYSTEM mode: Orb in the center, PLUS on one side, MINUS on the other. The Actor opens either side and adds resources or needs.

## Integration Item

The first canonical data object of this contour should be an `Integration Item`.

It is a formally manifested resource or need that Orb is allowed to use for matching.

Conceptually:

```text
integration_item_id
actor/profile
polarity: PLUS | MINUS
semantic_type
text/original_phrase
normalized_intent
quantity / unit
price or budget
geo / radius
availability window
preferred conditions
acceptable thresholds
visibility
matchability
status
provenance
created_from: manual | dialogue | voice | imported | other
```

An Integration Item is stronger than a casual sentence in discourse.

Example:

```text
"Мне бы сейчас водички"
```

is initially just discourse.

Orb may recognize it as a potential MINUS and ask:

```text
"Хочешь, внесём это в интеграцию?"
```

If the Actor accepts, the need becomes a matchable Integration Item.

The acceptance may be represented as a compact Integration Card. The card is effectively a small declaration/document in which the Actor confirms:
- this need/resource is real;
- Orb may use it for matching;
- the stated conditions are acceptable;
- if a qualifying match appears, Orb may show it as an actionable offer.

## Integration from ordinary dialogue

Integration must not require the Actor to open the PLUS/MINUS screen manually.

The same system should be callable from normal text, voice, Telegram, Web, Unity, a wearable/pendant or any other Orb channel.

Canonical flow:

```text
DISCOURSE
↓
COGNITIVE SYSTEM detects potential PLUS/MINUS
↓
GUIDE decides whether integration is relevant now
↓
DYNAMIC INTERFACE shows INTEGRATION CARD when appropriate
↓
ACTOR ACCEPT
↓
INTEGRATION ITEM becomes active/matchable
↓
MATCH ENGINE runs
↓
visual state / offers update
```

Orb should not force every casual desire into Integration. It may ask when the need/resource appears actionable and the Actor could benefit from a real match.

## Silent manual mode

In the manual Integration screen, Orb does not need to narrate every match.

The interface itself can communicate system state.

Example:

```text
Actor adds MINUS: "водичка"
↓
item appears in MINUS list
↓
matcher finds qualifying PLUS/product/service
↓
visual state of the item changes
↓
item becomes clickable
↓
click opens match/offer view
```

This is a canonical Dynamic Interface behavior:

> state change may be communicated visually without a flagship-model response.

The interface should therefore be able to update an Integration Item independently of conversation generation.

## Match visual states

Color is a useful first projection of match quality, but the semantic state must remain explicit in data.

Possible initial convention:

```text
neutral = no current match
GREEN   = direct / preferred match inside primary thresholds
BLUE    = acceptable alternative inside Actor-defined flexible thresholds
YELLOW  = stretch/opportunity match outside preferred settings but with a meaningful reason to consider
```

A yellow match could be surfaced, for example, because:
- it is significantly cheaper;
- delivery is much faster;
- it has a strong additional benefit;
- it is slightly outside preferred geography but otherwise excellent;
- it partially satisfies several needs at once.

The Actor should be able to configure how far Orb may search beyond preferred thresholds.

Colors are presentation. The underlying match should store reasons, scores and threshold decisions.

## Real matching factors

Matching is not just semantic similarity.

For a real-world match Orb may combine:
- semantic fit;
- exact/partial category match;
- quantity and units;
- price/budget;
- geography, radius and travel/delivery distance;
- time window / ETA;
- availability / inventory;
- Actor preferences;
- trust/reputation later;
- rights/access;
- delivery or fulfilment capability;
- alternative advantages;
- personal thresholds;
- hard constraints vs soft constraints.

This allows a MINUS to become a real operational request rather than a decorative wish.

## Match → Offer

When a qualifying match exists, Orb may surface it as an Offer.

Manual mode:

```text
MINUS item changes visual state
↓
Actor clicks
↓
MATCH VIEW
↓
one or more offers / partial matches
```

Conversational mode:

```text
Actor: "Хочу шампунь"
↓
Orb recognizes/creates MINUS
↓
matcher finds product cards
↓
Orb: "Глянь эти"
↓
PRODUCT / OFFER CARDS
```

Each card can be:
- opened for more information;
- ignored;
- compared;
- accepted.

Reading a card does not imply acceptance.

## Acceptance can execute fulfilment

For a fully specified real match, ACCEPT may immediately become execution.

Example voice flow:

```text
Actor: "Хочу огурчиков."
Orb: "Свеженьких, хрустящих, о которых мечтала утром?"
Actor: "Да."
Orb: "Килограмм хватит? Есть через 15 минут."
Actor: "Супер."
↓
OFFER CARD: 0.5/1 kg, price, seller/source, ETA
↓
ACCEPT
↓
Economy System charges balance
↓
Connector System starts delivery/fulfilment
↓
Action System tracks result
↓
State Delta
```

The Actor may complete this entire flow through voice without opening the Integration screen.

The screen remains a manual control surface for the same underlying objects.

## Matching/Merch Engine

The Matching/Merch Engine is an internal organ of Integration System, not a separate top-level Orb system.

Its job is to continuously or reactively compare active PLUS/MINUS items and other eligible integrated resources/offers.

It should support:
- exact matches;
- semantic matches;
- partial matches;
- threshold-based alternatives;
- geo filtering/ranking;
- price/budget ranking;
- time/availability ranking;
- multi-factor scoring;
- reason codes;
- match confidence;
- dedupe;
- expiration;
- reranking when world state changes.

Most of this should be server-side and deterministic/vector/graph-assisted. The flagship model is optional for explanation, interpretation or ambiguous cases.

## Progressive integration, not binary admission

Integration should be modeled as a set of states/facets rather than a single yes/no decision.

Possible lifecycle states:
- local_private;
- hidden;
- draft;
- structured;
- integration_candidate;
- matchable;
- graph_visible;
- shared;
- reusable;
- monetizable;
- suspended;
- archived.

A single object can be advanced on some axes while remaining restricted on others.

Examples:
- structured and vectorized, but private;
- matchable, but not publicly browsable;
- visible in the Actor's graph, but not public;
- public, but not reusable by others;
- reusable with attribution, but not monetized;
- monetizable with defined royalty/ownership rules.

## Integration passport

Instead of one numeric integration score, the system should eventually describe several dimensions:

```text
structure_state
visibility_state
graph_state
match_state
rights_state
reuse_state
economy_state
provenance_state
version_state
```

This allows Orb to answer not only “is it integrated?” but “how integrated is it, in what sense, and what next transition is available?”

## Core question

> How can this Actor or object become a meaningful part of Neo World, what part is already integrated, what remains private or draft, and what next transition is available?

## Candidate types

- Actor/profile manifestation;
- PLUS resource;
- MINUS need;
- project;
- artifact/work/book;
- knowledge block;
- content;
- method/service;
- event/news item;
- site;
- organization;
- place;
- product/offering;
- token/NFT;
- world/space/game object;
- external data obtained through Connector System;
- structured containers produced by INFOTEKA or another processing module.

## Target flow

```text
RAW / PERSONAL / EXTERNAL MATERIAL
↓
OPTIONAL PROCESSING / STRUCTURING
↓
AUTHORSHIP / SOURCE / PROVENANCE
↓
TYPE / SEMANTIC FORM
↓
INTEGRATION STATE
↓
RIGHTS / VISIBILITY / REUSE POLICY
↓
ENTITY / PASSPORT / CONTENT FORM
↓
RELATIONS
↓
GRAPH PRESENCE
↓
DISCOVERY / MATCHING / RETRIEVAL
↓
OPTIONAL ECONOMIC RIGHTS
↓
STATE DELTA
```

## Integration and matching

PLUS/MINUS matching is the first form of practical integration because it exposes selected Actor state to the common field in a machine-readable form.

Later matching can expand across:
- resources ↔ needs;
- products ↔ demand;
- people ↔ projects;
- projects ↔ capabilities;
- artifacts ↔ audiences;
- knowledge ↔ questions;
- places ↔ activities;
- services ↔ demand;
- content ↔ reusable contexts;
- world objects ↔ actors/systems.

## Authorship continuity

Integration must preserve provenance and continuity of authorship.

A content block or artifact should retain, where applicable:
- original source;
- author/owner;
- transformations;
- derivative relations;
- version history;
- visibility rules;
- reuse permissions;
- economic/royalty rules.

This is necessary for future reuse and monetization by other Neo World Actors and systems.

## Relationship with INFOTEKA

INFOTEKA is a module that can inspect raw information and decompose it into reusable containers.

Metaphorically:

```text
RAW MATERIAL
↓
INFOTEKA DISASSEMBLY
├─ useful semantic block A
├─ useful semantic block B
├─ media / artifact component
├─ entity/relation candidate
├─ social-content candidate
└─ noise / cache / irrelevant material → discard
```

The resulting containers may be consumed by many systems:
- Information System;
- Integration System;
- Memory System;
- Dynamic Interface System;
- Page/Site builders;
- SMM/content production;
- Entity/Graph System.

INFOTEKA is optional for Actors. The platform itself may use similar internal processing pipelines, but a user may simply use YNY CHAT without integrating or structuring anything for the shared field.

## Relationship with Connector System

Connector System provides two-way technical access between Orb and external accounts/services.

Connector may read or write without integration.

Example:

```text
Telegram channel connected
↓
Orb can read authorized material
↓
material may remain a private source of truth
↓
optional INFOTEKA processing
↓
optional Integration
↓
selected structures become part of Actor/system graph or shared Neo World field
```

For fulfilment, Integration may also hand an accepted match to Connector System for delivery, messaging, booking, publishing or another external action.

## Relationship with Information System

Information System answers what Orb can know/retrieve/use.

Integration System answers what selected information or manifestations become part of the unified Neo World structure and under which visibility/rights/reuse states.

## Relationship with Dynamic Interface System

Dynamic Interface System renders Integration Items and their live match state.

It should support:
- PLUS/MINUS lists;
- color/state changes without flagship narration;
- clickable matched items;
- Integration Cards created from dialogue;
- match/offer views;
- product/service cards;
- accept controls;
- live updates when match state changes.

## Relationship with Entity / Relation / Graph System

Integration progressively creates or updates:
- canonical entities;
- passports;
- relations;
- graph visibility;
- discovery/matching surfaces.

Graph and vector systems can assist matching, but integration state/rights remain authoritative.

## Relationship with Economy & Offer System

Integrated objects may later become eligible for:
- paid reuse;
- royalties;
- licensing;
- paid access;
- services;
- product offers;
- transactions;
- revenue sharing.

For matched goods/services, Economy System owns price truth, balance, transaction and payment state.

Economic eligibility is a later integration dimension, not a prerequisite for basic participation.

## Relationship with State System

Every meaningful integration transition can be recorded as a State Delta.

Examples:

```text
PLUS absent → PLUS resource published
need in discourse → confirmed MINUS item
MINUS unmatched → matched
match visible → offer accepted
need active → need fulfilled
draft → structured
private → graph_visible
shared → reusable
reusable → monetizable
```

## Canonical rules

> Integration means progressive participation in the whole.

> PLUS/MINUS is the first executable integration contour.

> A casual phrase may become an Integration Item only with sufficient Actor intent/acceptance.

> Matching may change the interface without requiring the flagship model to speak.

> Integration is voluntary: an Actor may remain almost entirely private and still use Orb/YNY CHAT.

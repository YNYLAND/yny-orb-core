# INTEGRATION MATCHING / MERCH ENGINE

## Role

The Matching/Merch Engine is an internal organ of Orb Integration System.

Its purpose is to turn active PLUS/MINUS Integration Items and other eligible integrated offers/resources into real, ranked matches that can become contacts, exchanges, offers, transactions or fulfilment.

It is not a top-level Orb system.

## Core loop

```text
ACTIVE MINUS / REQUEST
        ↓
NORMALIZE + EMBED + FILTER
        ↓
SEARCH ELIGIBLE PLUS / PRODUCT / SERVICE / RESOURCE
        ↓
HARD CONSTRAINTS
        ↓
SOFT THRESHOLDS
        ↓
VECTOR / GRAPH / STRUCTURED MATCH
        ↓
RANK + EXPLAIN REASONS
        ↓
MATCH STATE
        ↓
DYNAMIC INTERFACE UPDATE
        ↓
OPTIONAL OFFER
        ↓
ACCEPT → ACTION / ECONOMY / CONNECTOR
```

## Match inputs

Possible factors:
- semantic meaning;
- entity/category type;
- exact vs partial fit;
- quantity / unit;
- price / budget;
- location / radius / travel time;
- delivery ETA;
- availability window;
- inventory;
- Actor-defined preferences;
- hard constraints;
- acceptable alternatives;
- quality/trust later;
- rights/access;
- fulfilment capability;
- additional benefits;
- graph distance/relations;
- past Actor choices later.

## Match states

Presentation may use color, but storage should use semantic states/reasons.

Suggested projection:

```text
NONE / NEUTRAL
no qualifying match

GREEN
preferred/direct match inside primary thresholds

BLUE
acceptable alternative inside flexible thresholds

YELLOW
stretch/opportunity match outside preferred settings but with a meaningful reason to consider
```

Colors are not truth; the engine should store scores and reason codes.

## Example reason codes

- exact_semantic_match
- partial_semantic_match
- preferred_geo
- outside_preferred_geo
- within_budget
- below_budget
- faster_delivery
- extra_benefit
- partial_quantity
- alternative_variant
- trusted_source
- bundle_advantage
- multi_need_coverage

## Manual mode

No flagship response is required.

```text
Actor adds item
↓
matcher runs
↓
item state changes visually
↓
matched item becomes clickable
↓
click opens match view
```

## Conversational / voice mode

The same engine can operate without the manual screen.

```text
Actor discourse
↓
potential MINUS/PLUS detected
↓
Actor confirms Integration Item
↓
matcher runs
↓
Orb may surface one or more offer cards
```

## Offer generation

The engine should not fabricate price, inventory or delivery promises.

An actionable offer requires validated source data from Economy/Connector/Provider systems.

Offer can include:
- matched item/service/product;
- quantity;
- total price;
- provider/owner;
- ETA/location;
- why it matched;
- any deviation from preferred thresholds;
- accept action.

## Acceptance

```text
OFFER
↓
ACCEPT
↓
Action System validates
↓
Economy System transacts if needed
↓
Connector System fulfils externally if needed
↓
State System records fulfilment delta
```

## Cost principle

Most matching should be performed without flagship generation.

Use:
- structured indexes;
- vector retrieval;
- graph search;
- deterministic filters;
- ranking rules.

Use flagship/other model only for:
- ambiguous intent interpretation;
- explanation of unusual matches;
- negotiation/clarification;
- natural dialogue around a match.

## Canonical rule

> Orb should be able to make the world respond to a manifested need without requiring the Actor to navigate an interface.

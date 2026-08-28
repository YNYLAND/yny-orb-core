# PROFILE → ACCOUNT purchase v1

Status: **YNY DEV**

## Canon

- Actor/payer: authenticated `PROFILE`.
- Created entity: `neo.profile.acaunt` (`ACCOUNT`).
- System price: `1.00 YNY`.
- This is a **system purchase**, not an inter-profile transaction.
- No Neo World transaction tax is charged on this purchase.
- The transaction contour is reserved for transfers / transactions between Profiles.
- One Account per Profile in v1.
- Repeated create requests are idempotent: return the existing Account and charge `0 YNY`.
- The Account stores its own purchase receipt fields (`purchase_id`, `purchase_price_yny`, `purchase_kind=system_purchase`) instead of creating an inter-profile transaction record.

## Backend

Edge Function: `orb-account`

Supported actions:

### `quote`

Returns the current Account offer for the authenticated Profile:

- `price_yny`
- `charge_yny`
- `balance_yny`
- `can_purchase`
- `missing_yny`
- `purchase_kind=system_purchase`
- `already_created`
- `account_id` when already created

### `create`

Atomically:

1. locks the active Profile;
2. checks whether Account already exists;
3. reads the live YNY MENU price;
4. locks Profile balance;
5. checks the required `1.00 YNY`;
6. deducts `1.00 YNY` from the Profile balance;
7. creates Account with its system-purchase receipt (`purchase_id`, `purchase_price_yny=1.00`, `purchase_kind=system_purchase`).

No Neo World tax is added and no row is created in the inter-profile transaction ledger for this system purchase.

## Authentication

The browser never sends an arbitrary `profile_id` for purchase.

`orb-account` resolves the Profile from one of these verified identities:

- existing Orb Session `session_token` (compatible with current Orb Web / YNY MENU handoff flow);
- signed Telegram init data;
- Supabase Auth bearer token.

## PROFILE button contract

Add `ACCOUNT` to the authenticated Profile bar.

### Guest

Click `ACCOUNT` → use the existing Profile login flow. No offer can be accepted as Guest.

### Authenticated Profile, no Account

Click `ACCOUNT` → `quote` → show an offer card:

- `ACCOUNT` — `1.00 YNY`
- current Profile balance
- primary action: `КУПИТЬ ЗА 1 YNY`

Accept → `create`.

### Insufficient balance

Do not create Account. Show the existing balance/top-up action (`ПОПОЛНИТЬ БАЛАНС`).

### Success

- update visible Profile balance from `balance_yny` returned by the server;
- keep `ACCOUNT` as the entry point;
- subsequent click opens the existing Account instead of showing the purchase offer.

### Already created / repeated click

`quote` or `create` returns the existing `account_id`. No additional YNY is charged.

## Acceptance test passed in YNY DEV

Seed balance: `2.00 YNY`.

First purchase:

- system price: `1.00 YNY`;
- charged: `1.00 YNY`;
- resulting balance: `1.00 YNY`;
- Account created;
- `purchase_kind = system_purchase`;
- `purchase_transaction_id = null`;
- inter-profile transaction ledger rows for this Profile: `0`.

Repeated purchase:

- same Account remains;
- no additional charge;
- no transaction-ledger row is created;
- balance remains `1.00 YNY`.

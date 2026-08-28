# PROFILE → ACCOUNT purchase v1

Status: **YNY DEV**

## Canon

- Actor/payer: authenticated `PROFILE`.
- Created entity: `neo.profile.acaunt` (`ACCOUNT`).
- Base price: `1.00 YNY`.
- Neo World tax: `1%` paid by the actor on top of the price = `0.01 YNY`.
- Total charge: `1.01 YNY`.
- One Account per Profile in v1.
- Repeated create requests are idempotent: return the existing Account and charge `0 YNY`.
- Price and tax are written as separate balance transactions.

## Backend

Edge Function: `orb-account`

Supported actions:

### `quote`

Returns the current Account offer for the authenticated Profile:

- `price_yny`
- `neo_tax_rate`
- `neo_tax_yny`
- `charge_yny`
- `balance_yny`
- `can_purchase`
- `missing_yny`
- `already_created`
- `account_id` when already created

### `create`

Atomically:

1. locks the active Profile;
2. checks whether Account already exists;
3. reads the live YNY MENU price;
4. locks Profile balance;
5. checks total funds (`price + tax`);
6. deducts the total;
7. writes the `1.00 YNY` price transaction;
8. writes the separate `0.01 YNY` Neo World tax transaction;
9. creates Account and links it to Profile and purchase transaction.

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
- `Налог Нео Мира 1%` — `0.01 YNY`
- `Итого` — `1.01 YNY`
- current Profile balance
- primary action: `КУПИТЬ ЗА 1.01 YNY`

Accept → `create`.

### Insufficient balance

Do not create Account. Show the existing balance/top-up action (`ПОПОЛНИТЬ БАЛАНС`).

### Success

- update visible Profile balance from `balance_yny` returned by the server;
- keep `ACCOUNT` as the entry point;
- subsequent click opens the existing Account instead of showing the purchase offer.

### Already created / repeated click

`quote` or `create` returns the existing `account_id`. No additional price or tax is charged.

## Acceptance test already passed in YNY DEV

Seed balance: `2.00 YNY`.

First purchase:

- price: `1.00 YNY`;
- tax: `0.01 YNY`;
- charged: `1.01 YNY`;
- resulting balance: `0.99 YNY`;
- Account created;
- one price transaction + one tax transaction.

Repeated purchase:

- same Account remains;
- no additional transactions;
- balance remains `0.99 YNY`.

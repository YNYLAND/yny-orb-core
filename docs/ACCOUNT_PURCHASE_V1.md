# PROFILE → ACCOUNT purchase v1

Status: **YNY DEV**

## Canon

- Actor/payer: authenticated `PROFILE`.
- Created entity: `neo.profile.acaunt` (`ACCOUNT`).
- System price: `1.00 YNY` per Account.
- `ACCOUNT` is a repeatable creatable entity, not a one-time module entitlement.
- Every accepted purchase creates exactly one new Account.
- A Profile may own multiple Accounts.
- New Accounts are created as `BLANK` and appear immediately in the Profile Account list.
- An Account can later be configured into a form such as `GROUP`, `PAGE`, `ASSYS`, `WALLET`, or `CABINET`.
- This is a **system purchase**, not an inter-profile transaction.
- No Neo World transaction tax is charged on this purchase.
- The transaction contour is reserved for transfers / transactions between Profiles.
- The Account stores its own purchase receipt fields (`purchase_id`, `purchase_price_yny`, `purchase_kind=system_purchase`) instead of creating an inter-profile transaction record.

## Backend

Edge Function: `orb-account`

Supported actions today:

### `quote`

Returns the current Account offer for the authenticated Profile plus the current owned Account list:

- `price_yny`
- `charge_yny`
- `balance_yny`
- `can_purchase`
- `missing_yny`
- `purchase_kind=system_purchase`
- `repeatable=true`
- `account_count`
- `accounts[]`

Each item in `accounts[]` includes the Account id, display name, form, status, purchase receipt and timestamps.

### `create`

Atomically:

1. locks the active Profile;
2. reads the live YNY MENU price;
3. locks Profile balance;
4. checks the required `1.00 YNY`;
5. deducts `1.00 YNY` from the Profile balance;
6. creates one new Account with `account_form=blank`;
7. stores its system-purchase receipt (`purchase_id`, `purchase_price_yny=1.00`, `purchase_kind=system_purchase`).

No Neo World tax is added and no row is created in the inter-profile transaction ledger for this system purchase.

A v2 purchase RPC also supports `purchase_request_id` idempotency for UI retries/double-submit protection.

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

### Authenticated Profile

Click `ACCOUNT` → `quote` → open the Account panel.

The panel contains:

- the list of already owned Accounts;
- a `+ ACCOUNT` / `СОЗДАТЬ ACCOUNT` action;
- the YNY MENU offer: `ACCOUNT — 1.00 YNY`;
- current Profile balance.

Accept → `create`.

### Insufficient balance

Do not create Account. Show the existing balance/top-up action (`ПОПОЛНИТЬ БАЛАНС`).

### Success

- deduct exactly `1.00 YNY`;
- create one new `BLANK` Account;
- append it to the Account list immediately;
- update visible Profile balance from `balance_yny` returned by the server;
- keep the purchase action available for the next Account.

## Account forms

The Account entity is purchased first and receives its functional form later.

Current canonical forms:

- `BLANK` — empty Account shell;
- `GROUP` — community/group Account;
- `PAGE`;
- `ASSYS`;
- `WALLET`;
- `CABINET`.

The immediate product target after Account purchasing/listing is the first `GROUP` Account for a community.

## Acceptance test passed in YNY DEV

A test Profile was left with three distinct Accounts:

- all three belong to the same Profile;
- all three have separate `purchase_id` values;
- all three start as `account_form=blank`;
- each new Account costs exactly `1.00 YNY`;
- the Account offer remains repeatable after purchase;
- no inter-profile transaction-ledger row is created by Account purchases.

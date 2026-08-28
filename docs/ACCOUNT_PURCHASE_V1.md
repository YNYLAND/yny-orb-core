# PROFILE → ACCOUNT / shell + modules

Status: **YNY DEV**

## Canon

- Actor/payer: authenticated `PROFILE`.
- Entity: `neo.profile.acaunt` (`ACCOUNT`).
- System price: `1.00 YNY` per Account.
- `ACCOUNT` is repeatable: every accepted purchase creates one new Account shell.
- A Profile may own multiple Accounts.
- System purchase is not an inter-profile transaction and has no Neo World transaction tax.
- Each Account keeps its own system-purchase receipt (`purchase_id`, `purchase_price_yny`, `purchase_kind=system_purchase`).

## Account is not a form

An Account never turns into GROUP, PAGE, ASSYS, WALLET or CABINET.

The Account is a stable shell/container. Functional capabilities are installed **inside the same Account as modules** and may coexist.

Example:

`ACCOUNT`
- `PAGE`
- `GROUP`
- other modules as needed

Unused modules stay uninstalled so the Account workspace is not cluttered.

## Purchase → setup

Purchase creates a paid empty Account slot immediately in the Profile Account list:

- `setup_state=blank`
- no required module installed
- no Account form
- own `purchase_id`
- own list position

The user then fills the shell. In v1 the minimum required field is the Account name.

After naming:

- `setup_state=ready`
- optional avatar may be attached
- modules can be installed into the Account

## Profile Account list

For now the Profile Account panel is deliberately simple:

- avatar
- Account name
- blank shell may show as an unfinished item
- manual ordering is supported through `list_position`

Up to roughly 10 Accounts this remains a plain ordered list. Search/catalog/grouping is a later UI layer, not required for the first version.

## Account module model

Current module catalog in DEV:

- `PAGE`
- `GROUP`
- `ASSYS`
- `WALLET`
- `CABINET`

Installing one module does not replace another.

### PAGE

PAGE is installed into the Account and becomes a public/shareable surface. Its public address/domain and link model are the next layer.

### GROUP

GROUP is a bundle/ready unpacking installed inside the Account. The first DEV manifest unpacks:

- `TOPICS`
- `ROOMS`
- `CHATS`
- `FEED`
- `ORB`

These belong to the Group package inside that Account; the Account itself remains unchanged.

Future Group behavior includes profiles/membership, voice rooms, streams/live participation and the Account Orb carrying community knowledge.

## Public onboarding target

Target behavior for a public Account/PAGE link:

1. visitor opens a shared Account page;
2. if the visitor has no platform Profile, a Profile is created/onboarded;
3. when that Account has an active GROUP module and the link is configured for joining, the Profile is automatically added to that Group;
4. the public PAGE can expose the project/community map and links into its worlds.

This onboarding contract is intentionally documented now but membership/link implementation is a later vertical slice.

## Backend in YNY DEV

Core RPCs:

- `get_profile_account_quote_v1(profile)` — Account offer + ordered Account list
- `purchase_profile_account_repeatable_v1(profile, ..., request_id)` — buy one empty Account shell
- `configure_profile_account_v1(profile, account, name, avatar)` — finish minimum setup
- `get_profile_accounts_v1(profile)` — ordered simple list
- `reorder_profile_account_v1(profile, account, position)` — manual ordering
- `install_account_module_v1(profile, account, module)` — install/unpack a module
- `get_account_workspace_v1(profile, account)` — Account + installed modules/components

Tables:

- `accounts`
- `account_module_catalog`
- `account_modules`
- `account_module_components`

The former `account_form` field has been removed from DEV because it encoded the wrong model.

## Acceptance test

Validated in YNY DEV:

1. Profile buys a new Account for exactly `1.00 YNY`.
2. New Account appears as `setup_state=blank`.
3. Account is named `YNY Community` and becomes `ready`.
4. `PAGE` is installed into that Account.
5. `GROUP` is installed into the same Account.
6. GROUP unpacks `TOPICS`, `ROOMS`, `CHATS`, `FEED`, `ORB`.
7. PAGE and GROUP coexist in the same Account workspace.
8. No inter-profile transaction-ledger row is created by the Account purchase.

# Cabinet Account DEV Environment

The accessible GitHub repositories and branches are development/test space only. They are not the live production Cabinet source.

## Environment boundaries

- GitHub: DEV/test by default.
- Current feature branch: `cabinet-account-dev` for convenience only.
- Supabase: `YNY DEV` only for Account development data and test balances.
- Production Supabase must not be modified by Account DEV operations.
- Cloudflare deployment, when added, must use a separate DEV Pages/Worker project and DEV hostname.
- The live production Cabinet is a separate published environment and is not touched until explicit acceptance.

## Purchase rule

1 YNY buys one additional blank Account container. Editing/reconfiguring a purchased container is not a new purchase. System purchase does not enter the Profile↔Profile transaction/tax contour.

## Current Account model

Account is a stable neutral shell. PAGE, GROUP, ASSYS, WALLET and CABINET are installable modules that may coexist inside the same Account.

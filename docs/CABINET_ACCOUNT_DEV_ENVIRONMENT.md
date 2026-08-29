# Cabinet Account DEV Environment

This branch is reserved for the isolated PROFILE → ACCOUNT development slice.

## Environment boundaries

- Git branch: `cabinet-account-dev`
- Supabase: `YNY DEV` only
- Production Supabase must not be modified by Account DEV operations.
- Cloudflare deployment, when added, must use a separate DEV Pages/Worker project and DEV hostname.
- Production Cabinet (`cabinet.yny.land`) is not a deployment target for this branch.
- Promotion to production requires explicit acceptance after DEV testing.

## Purchase rule

1 YNY buys one additional blank Account container. Editing/reconfiguring a purchased container is not a new purchase. System purchase does not enter the Profile↔Profile transaction/tax contour.

## Current Account model

Account is a stable neutral shell. PAGE, GROUP, ASSYS, WALLET and CABINET are installable modules that may coexist inside the same Account.

# Architecture Checks

Use this command from repository root to validate required structure:

```bash
node tools/check-architecture.mjs
```

The check verifies:

- Core folders under lib/core
- Required feature layered folders and routes.dart for:
  - auth
  - home
  - flights
  - hotels
  - weather
  - trips
  - wallet
  - translator
  - payments
  - ai
  - profile
  - settings
- Backend src layered folders and app.js

You can wire this command into CI as a required check before merge.

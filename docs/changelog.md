# Changelog

## Unreleased

### Added
- Authentication social sign-in support with Google and Apple providers.
- Auth provider identity helpers: current user, user id, and immediate user lookup.
- Wallet domain and in-memory repository scaffolding required by current provider wiring.

### Changed
- Splash authentication check now uses Riverpod auth provider instead of direct auth service instance.
- Login flow now includes explicit social sign-in actions and error handling.
- Router/trip provider unblock updates to restore buildability on auth branch.

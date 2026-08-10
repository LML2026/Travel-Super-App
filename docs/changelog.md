# Changelog

## Unreleased

### Added
- TSAPP-ID-103 backlog ticket for user profile module kickoff.
- Authentication social sign-in support with Google and Apple providers.
- Auth provider identity helpers: current user, user id, and immediate user lookup.
- Wallet domain and in-memory repository scaffolding required by current provider wiring.

### Changed
- Phase 1 branding transition completed: user-visible app and documentation branding updated from Travel Super App to ITAREVO, while package, bundle, Firebase, signing, and release identifiers remain unchanged.
- Splash authentication check now uses Riverpod auth provider instead of direct auth service instance.
- Login flow now includes explicit social sign-in actions and error handling.
- Router/trip provider unblock updates to restore buildability on auth branch.
- Sprint and project boards updated: TSAPP-ID-102 moved to review, TSAPP-ID-103 moved to in progress.

### Fixed
- No workspace diagnostics currently reported by VS Code error scan.

### Known Issues
- Flutter web login smoke in shared browser currently throws repeated removeChild null runtime errors from main.dart.js.

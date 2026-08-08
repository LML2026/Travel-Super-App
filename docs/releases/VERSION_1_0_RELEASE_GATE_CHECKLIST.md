# Version 1.0 Release Gate Checklist

Date: 2026-08-04
Decision: Feature freeze declared for Version 1.0
Rule: No major feature development until release gates pass

Execution artifacts:
- docs/releases/VERSION_1_0_PRODUCTION_AUDIT_WEEK_PLAN.md
- docs/releases/VERSION_1_0_AUDIT_REPORT_TEMPLATE.md

## Phase 1 - Production Audit (1 week)

Audit matrix:

| Area | Status | Action Item |
|---|---|---|
| Authentication | Complete - audit pending | Verify sign-in, sign-out, session restore, and auth error handling on real devices |
| Trips | Complete - audit pending | Validate create, edit, delete, list, details, and persistence consistency |
| Flights | Complete - audit pending | Verify real provider paths, fallback behavior, and error surfaces |
| Hotels | Complete - audit pending | Verify provider response handling and search latency acceptance |
| Taxi | Complete - audit pending | Validate booking/search reliability and failure recovery states |
| Nearby Essentials | Complete - audit pending | Verify permission handling and response time target |
| Maps | Complete - audit pending | Validate key restrictions, loading state, and map fallback |
| AI Assistant | Complete - audit pending | Validate response quality, timeout handling, and retries |
| Budget | Complete - audit pending | Validate calculations and state recovery after app restart |
| Expenses | Complete - audit pending | Validate add/edit/delete and synchronization behavior |
| Notifications | Complete - audit pending | Validate scheduling, delivery, and permission edge cases |
| Wallet | Complete - audit pending | Validate balances, conversion consistency, and data integrity |
| Crash Reporting | Complete - audit pending | Confirm production crash capture and triage routing |
| Onboarding | Complete - audit pending | Validate completion funnel and drop-off instrumentation |
| Privacy | Complete - audit pending | Confirm policy links, consent capture, and data handling workflows |

Gate:
- Every row must be either Audit Passed or have a dated release-blocking action item.

## Phase 2 - Performance

Measure and track:
- cold app startup
- warm startup
- memory usage
- battery impact
- network usage
- AI response time
- maps loading
- nearby search
- search latency

Performance targets:
- app startup under 2 seconds
- AI under 5 seconds
- nearby under 2 seconds

Rule:
- Profile first. Optimize only where measurements show bottlenecks.

## Phase 3 - Security Review

Release gate checks:
- Firestore Rules
- Storage Rules
- API keys
- Environment variables
- Secrets
- Authentication
- Permissions
- Rate limiting
- Backend validation

Rule:
- Treat security findings as release blockers until resolved or explicitly accepted with mitigation.

## Phase 4 - User Experience Review

Every screen review prompts:
- Is the primary action obvious?
- Is the screen understandable without instructions?
- Is there a loading state?
- Is there an empty state?
- Is there a helpful error state?
- Can the user recover from failure?

## Phase 5 - Accessibility

Check:
- font scaling
- screen reader support
- color contrast
- tap target sizes
- keyboard navigation where applicable
- localization readiness

## Phase 6 - Store Readiness

Prepare and verify:
- App Store and Google Play descriptions
- screenshots
- feature graphic
- icon
- privacy policy
- terms of use
- support page
- FAQ
- contact email

## Phase 7 - Monitoring

Must answer before launch:
- How many users signed up?
- How many trips were created?
- Which features are most used?
- Where do users abandon onboarding?
- Where do crashes occur?
- Which screens are slow?

## Phase 8 - Public Launch

Staged rollout:
- Internal testers
- 100 beta users
- 500 users
- 2,000 users
- Public release

Rule:
- Expand only when each stage is stable and monitored.

## Version 1.1 Backlog Separation

Do not implement before Version 1.0 launch:
- Receipt OCR v2
- Offline maps
- Live airport assistant
- Voice assistant
- Public transport
- eSIM
- Insurance
- Loyalty programs
- Advanced AI itinerary optimization

## Final Release Rule
From feature freeze onward:
- only release-blocking bug fixes
- performance improvements driven by measurement
- UX polish and reliability hardening
- launch readiness and distribution tasks

## Launch Gate #1 - Authentication + Firestore Security Proof

Status: Implemented locally, CI verification pending
Date: 2026-08-08

Evidence captured:
- Firestore rules enforce per-user ownership under users/{userId}/**
- Firestore emulator rules suite passes (5/5) via functions test/firestore.rules.test.js
- Auth-focused Flutter tests pass (10/10) across test/features/auth and test/features/authentication
- CI workflow now includes:
	- Firestore security gate job (Java 21 + emulator rules tests)
	- Auth-focused Flutter test step in flutter-quality

Final decision rule for Gate #1:
- Mark Gate #1 PASS only after the new CI checks are green on the pushed commit.

## Launch Gate #2 - Production Configuration + Backend Security Hardening

Status: Implemented locally, CI verification pending
Date: 2026-08-08

Evidence captured:
- Backend CORS allowlist enforcement with production guard (`CORS_ALLOWED_ORIGINS` required in production)
- Backend rate limiting enabled on `/api` routes
- Route-scoped Firebase bearer auth with configurable protected prefixes (`AUTH_PROTECTED_PATHS`)
- Flight upstream timeout/retry handling hardened
- Backend env template added (`backend/.env.example`) and setup docs wired
- Local validation passed:
	- `node ../tools/check-openapi-contracts.mjs`
	- `node ../tools/check-api-spec-coverage.mjs`
	- `npm run test:contracts`
	- `node --check server.js`

Final decision rule for Gate #2:
- Mark Gate #2 PASS only after CI is green on the pushed commit and production environment variables are configured.

## Launch Gate #3 - Signing + Store Submission Readiness

Status: FAIL (blocking)
Date: 2026-08-08

Evidence captured:
- Release bundle is buildable locally (`build/app/outputs/bundle/release/app-release.aab` present)
- `android/key.properties` exists locally but still contains placeholder credentials
- `storeFile` points to `../keystore/upload-keystore.jks` and the keystore file is missing
- Build guard hardened to reject placeholder signing credentials and missing keystore file
- Secret hygiene guard added: `android/key.properties` and `keystore/*.jks` explicitly ignored in git

Blocking action items:
- Generate/import a real upload keystore at `keystore/upload-keystore.jks`
- Replace placeholder signing values in local `android/key.properties`
- Re-run release bundle build and record SHA-256 for the artifact
- Verify Play Console metadata links are live: privacy policy, terms, support

Final decision rule for Gate #3:
- Mark Gate #3 PASS only after a signed release AAB is produced with non-placeholder signing credentials, keystore presence is verified, and store policy/support URLs are confirmed live.

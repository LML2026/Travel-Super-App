# iOS TestFlight Internal Beta Runbook

Status: Active
Owner: Release Engineering
Scope: iOS internal beta as primary real-device path

## Goal
Ship each release candidate to TestFlight internal testers and run smoke checks on a real iPhone before public rollout.

## Why this path
- iPhone is currently the only guaranteed real test device.
- Android real-device validation is deferred until an Android tester/device is available.
- iOS TestFlight becomes the primary release confidence path for user-facing behavior.

## One-time setup
1. Apple Developer Program active for the app team.
2. App record exists in App Store Connect.
3. Bundle ID selected and reserved in Apple Developer portal.
4. GitHub repository secrets configured:
   - `APP_STORE_CONNECT_KEY_ID`
   - `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_API_KEY_P8`
   - `IOS_BUNDLE_ID` (example: `com.lml2026.travelsuperapp`)
   - `IOS_DEVELOPMENT_TEAM` (Apple Developer Team ID)
   - `IOS_SIGNING_CERTIFICATE_P12_BASE64` (base64-encoded iOS distribution certificate .p12)
   - `IOS_SIGNING_CERTIFICATE_PASSWORD` (password for the .p12)
   - `IOS_PROVISIONING_PROFILE_BASE64` (base64-encoded App Store provisioning profile .mobileprovision)
   - If the four iOS signing secrets above are missing, the workflow now exits successfully after setup and skips signed IPA/TestFlight upload with a warning.
5. iOS workflow present: [iOS TestFlight workflow](../../.github/workflows/ios-testflight.yml)
6. Export options present: [Export options plist](../../ios/ExportOptionsAppStore.plist)

## Pipeline trigger
Use GitHub Actions > iOS TestFlight > Run workflow.

Optional inputs:
- `build_name`: semantic version shown in TestFlight (e.g. 1.0.2)
- `build_number`: numeric build counter

If `build_number` is omitted, the workflow uses `github.run_number`.

## Expected pipeline output
1. Flutter dependencies resolved.
2. iOS pods installed.
3. IPA built at `build/ios/ipa/*.ipa`.
4. IPA uploaded as GitHub artifact.
5. IPA uploaded to TestFlight via App Store Connect API key.

## Internal tester flow
1. Add testers in App Store Connect Internal Testing group.
2. Assign new build to internal testing.
3. Install with TestFlight app on iPhone.

## Real-device smoke checklist (iPhone)
1. Install via TestFlight.
2. Onboarding flow.
3. Sign in.
4. Create and open trip.
5. Flights search.
6. Hotels search.
7. Wallet and budget interactions.
8. Nearby and maps flow.
9. AI assistant request and response.
10. Notification behavior validation.
11. Background app then reopen.
12. Sign out then sign in again.

## Release pass criteria
- All smoke checks pass on iPhone with no P0/P1 defects.
- No release-blocking auth, trip, search, wallet, maps, AI, or notification failures.
- Crash-free behavior during smoke run.

## Notes
- Keep Android CI builds green in parallel while Android real-device gate is deferred.
- Do not introduce net-new features during this stage; only release blockers and reliability fixes.

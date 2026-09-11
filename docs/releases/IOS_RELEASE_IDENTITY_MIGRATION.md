# iOS Release Identity Migration

This checklist is intentionally prepared without Apple account values. The current
placeholder bundle identifier remains `com.example.travelSuperApp` until ITAREVO
LTD's Apple Developer organization is active.

## When Apple access is active

1. Register `com.itarevo.travel` (or the final approved ITAREVO bundle identifier)
   in Apple Developer and App Store Connect.
2. Supply the following CI secrets to `.github/workflows/ios-testflight.yml`:
   `IOS_BUNDLE_ID`, `IOS_DEVELOPMENT_TEAM`, `IOS_PROVISIONING_PROFILE_NAME`,
   `IOS_SIGNING_CERTIFICATE_P12_BASE64`, `IOS_SIGNING_CERTIFICATE_PASSWORD`,
   `IOS_PROVISIONING_PROFILE_BASE64`, `APP_STORE_CONNECT_KEY_ID`,
   `APP_STORE_CONNECT_ISSUER_ID`, and `APP_STORE_CONNECT_API_KEY_P8`.
3. Create the matching iOS app in Firebase and regenerate the iOS section of
   `lib/firebase_options.dart`. Keep the Firebase project unchanged.
4. Update the Google Cloud iOS application restriction for the Maps key to the
   registered bundle identifier. The key value remains supplied only through the
   ignored `ios/Flutter/Local.xcconfig` or the CI `GOOGLE_MAPS_API_KEY` secret.
5. Verify the Google Sign-In iOS OAuth client and URL-scheme configuration for the
   new bundle identifier if the provider requires a regenerated client.

## Files affected by the migration

- `ios/Runner.xcodeproj/project.pbxproj`: Runner bundle identifier and release
  signing/team settings.
- `ios/ExportOptionsAppStore.plist`: bundle ID, team ID and provisioning profile
  name are injected by CI.
- `lib/firebase_options.dart`: regenerated iOS Firebase app identifiers.
- `ios/Runner/Runner.entitlements`: the Keychain group follows
  `$(AppIdentifierPrefix)$(CFBundleIdentifier)` and should remain derived.
- `ios/Runner/Info.plist`: the bundle identifier remains build-setting driven;
  existing location, microphone and speech descriptions remain valid.
- Google Cloud Console: update the Maps iOS bundle-ID restriction.

No Apple identifiers, certificates, provisioning profiles, API keys or credentials
belong in the repository.

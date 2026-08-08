# Setup

## Prerequisites
- Flutter SDK
- Node.js (LTS)
- Firebase project configuration

## App Setup
1. Install Flutter dependencies.
2. Configure Firebase options for target platforms.
3. Run app: flutter run

## Backend Setup
1. cd backend
2. npm install
3. copy backend/.env.example to backend/.env and configure values
4. set production-safe values before release (CORS_ALLOWED_ORIGINS, AUTH_REQUIRED, AUTH_PROTECTED_PATHS, FIREBASE_PROJECT_ID)
4. node server.js

## Recommended Validation
- From repository root: node tools/check-architecture.mjs
- Flutter static checks: flutter analyze
- Feature tests: flutter test test/features/trips

## Notes
- AI planner supports fallback mode when no provider key is configured.

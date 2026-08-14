# ITAREVO Backend Deployment

This service is prepared for a later Cloud Run deployment. Deployment and Google Cloud configuration are intentionally separate operations.

## Runtime

- Node.js 22 slim runtime image
- Compiled entry point: `dist/src/server.js`
- Start command: `npm start`
- Port: Cloud Run supplies `PORT`; local fallback is `8080`
- Runtime user: non-root `node`

## Environment

Required for an explicitly activated Google provider:

```text
TRANSLATION_PROVIDER=google
GOOGLE_CLOUD_PROJECT=travel-super-app-a47cb
GOOGLE_TRANSLATION_LOCATION=global
```

Optional browser CORS configuration:

```text
ITAREVO_ALLOWED_ORIGINS=http://localhost:8080,https://your-approved-itarevo-web-origin.example
```

Use a comma-separated allowlist. If it is absent, browser origins are rejected; native clients without an `Origin` header remain unaffected.

## Identity and credentials

The Cloud Run service must use the dedicated `ITAREVO Translator Backend` service identity. Firebase Admin and Cloud Translation use Application Default Credentials from the runtime identity. Do not create, copy, or mount a service-account JSON key.

The runtime identity requires the minimum approved Cloud Translation permission, currently `roles/cloudtranslate.user`, subject to final IAM review.

## Endpoints

- `GET /healthz` returns `{ "status": "ok" }` without authentication or provider access.
- `POST /translate` requires a verified Firebase ID token and approved CORS origin when called by a browser.

## Local commands

```text
npm ci
npm run typecheck
npm test
npm run build:prod
npm start
```

No translation provider is active unless `TRANSLATION_PROVIDER=google` and `GOOGLE_CLOUD_PROJECT` are explicitly configured.

## Image boundary

The final image contains production dependencies and compiled `src` output only. Tests, host `node_modules`, host `dist`, Git metadata, logs, environment files, and credential-file patterns are excluded by `.dockerignore` or the multi-stage build.
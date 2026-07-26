# API

## Base URL
- Local: http://localhost:5000

## Core Endpoints
- POST /api/flights/search
- GET /api/hotels/search
- GET /api/weather
- GET /api/places/nearby
- GET /api/currency/rate
- POST /api/ai/travel-plan

## Contract Notes
- Responses should return a stable JSON shape.
- Validation errors should return explicit messages.
- Provider failures should return safe fallbacks where implemented.

## Source of Truth
- Full API specification: API_SPEC.md
- OpenAPI schema: openapi.yaml

## Backend Layout
- Routes: backend/src/routes
- Controllers: backend/src/controllers
- Composition entry: backend/server.js

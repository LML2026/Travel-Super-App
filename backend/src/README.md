# Backend src Layout

This folder is the target backend architecture:

- `config/`: environment config and runtime settings
- `middleware/`: auth, validation, error middleware
- `validators/`: request validation rules and schemas
- `models/`: DTO/schema definitions
- `routes/`: endpoint route declarations
- `controllers/`: request handlers
- `services/`: business logic
- `repositories/`: data access and provider adapters
- `utils/`: shared backend helpers
- `app.js`: Express app composition root

Current runtime still uses `backend/server.js`. Migrate modules into `src/` incrementally and keep behavior unchanged while refactoring.

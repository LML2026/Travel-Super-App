# Feature Structure Contract

Each feature should follow:

```text
<feature>/
  data/
    models/
    repositories/
    services/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    providers/
    screens/
    widgets/
  routes.dart
```

Guidelines:

- Keep all API/Firestore integration in `data/`
- Keep business rules in `domain/usecases/`
- Keep Riverpod providers in `presentation/providers/`
- Keep UI-only code in `presentation/screens/` and `presentation/widgets/`
- Keep route constants/builders in `routes.dart`

Legacy folders (`models/`, `screens/`, `providers/`) may coexist during migration.

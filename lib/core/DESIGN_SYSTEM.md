# Design System

Shared UI primitives live under `lib/core/theme/` and `lib/core/widgets/`.

## Theme tokens

Use these files for visual consistency:
- `app_colors.dart`: app color palette
- `app_spacing.dart`: spacing scale
- `app_radii.dart`: border radius scale
- `text_styles.dart`: typography presets
- `app_theme.dart`: global Material theme

## Shared widgets

Use these before creating feature-specific UI wrappers:
- `AppPrimaryButton`
- `AppSecondaryButton`
- `AppCard`
- `AppInputField`
- `AppEmptyState`

Import barrel files when possible:

```dart
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
```

## Usage examples

### Primary button

```dart
AppPrimaryButton(
  label: 'Search Hotels',
  icon: Icons.search,
  onPressed: _triggerSearch,
)
```

### Secondary button

```dart
AppSecondaryButton(
  label: 'Save',
  icon: Icons.favorite_border,
  onPressed: _toggleSave,
)
```

### Card container

```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text('Section title'),
    ],
  ),
)
```

### Input field

```dart
AppInputField(
  controller: _cityController,
  label: 'City',
  hint: 'e.g. Paris',
  prefixIcon: Icons.location_city,
)
```

### Empty state

```dart
const AppEmptyState(
  icon: Icons.hotel,
  title: 'No hotels found',
  message: 'Try another destination or different dates.',
)
```

## Adoption rule

When building new UI:
1. Start with tokens from `lib/core/theme/`.
2. Reuse shared widgets from `lib/core/widgets/`.
3. Only create feature-local widgets when behavior is domain-specific.
4. If a pattern repeats across two features, promote it into `lib/core/widgets/`.

# UI Component Library Standard

## Goal
Ensure visual consistency and reduce duplicated UI logic by using shared components from core before creating feature-local widgets.

## Source of Truth
- Theme tokens: lib/core/theme
- Shared widgets: lib/core/widgets

## Core Theme Tokens
- AppColors
- AppSpacing
- AppRadii
- AppTextStyles
- AppTheme

## Shared Components
- AppCard
- AppTextField
- AppInputField
- PrimaryButton
- SecondaryButton
- AppPrimaryButton
- AppSecondaryButton
- LoadingIndicator
- AppEmptyState
- ErrorView
- PriceTag
- RatingBadge

## Usage Rules
1. If a UI pattern exists in core, use it.
2. If a pattern appears in two features, promote it to core.
3. Feature-local widgets should contain domain behavior, not generic styling.
4. Do not introduce one-off spacing or colors without a token.

## Screen Composition Template
Each production screen should include:
- Loading state
- Empty state
- Error state
- Content state
- Primary and secondary action behavior

## Accessibility Minimums
- Text contrast follows WCAG AA.
- Interactive elements have touch targets >= 44x44.
- Semantics labels for non-text controls.

## Migration Backlog
- Replace ad-hoc buttons with PrimaryButton or AppPrimaryButton.
- Replace direct TextField usage with AppTextField or AppInputField where possible.
- Normalize spacing to AppSpacing values.

## Review Checklist
- Uses only design tokens for color, spacing, radius.
- Reuses existing components first.
- Handles loading, error, and empty states.
- No duplicated generic widget logic.

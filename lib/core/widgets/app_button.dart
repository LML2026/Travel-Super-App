import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tertiary }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final Widget? leadingIcon;
  final Widget? trailingIcon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();
    if (!fullWidth) return button;

    return SizedBox(width: double.infinity, child: button);
  }

  Widget _buildButton() {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final content = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    switch (variant) {
      case AppButtonVariant.primary:
        return _filledButton(effectiveOnPressed, content);
      case AppButtonVariant.secondary:
        return _tonalButton(effectiveOnPressed, content);
      case AppButtonVariant.tertiary:
        return TextButton(onPressed: effectiveOnPressed, child: content);
    }
  }

  Widget _filledButton(VoidCallback? onTap, Widget content) {
    if (isLoading || (leadingIcon == null && trailingIcon == null)) {
      return FilledButton(onPressed: onTap, child: content);
    }

    return FilledButton.icon(
      onPressed: onTap,
      icon: leadingIcon ?? const SizedBox.shrink(),
      label: trailingIcon == null
          ? content
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                const SizedBox(width: AppSpacing.xs),
                trailingIcon!,
              ],
            ),
    );
  }

  Widget _tonalButton(VoidCallback? onTap, Widget content) {
    if (isLoading || (leadingIcon == null && trailingIcon == null)) {
      return FilledButton.tonal(onPressed: onTap, child: content);
    }

    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: leadingIcon ?? const SizedBox.shrink(),
      label: trailingIcon == null
          ? content
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                content,
                const SizedBox(width: AppSpacing.xs),
                trailingIcon!,
              ],
            ),
    );
  }
}

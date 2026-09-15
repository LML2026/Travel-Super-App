import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 1,
      color: AppColors.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.navy50,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.navy),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textNavy,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            DefaultTextStyle.merge(
              style: AppTextStyles.body.copyWith(color: AppColors.textNavy),
              child: IconTheme.merge(
                data: const IconThemeData(color: AppColors.navy),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

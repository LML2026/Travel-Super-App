import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool showDivider;

  const SectionTitle({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (actionText != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(
            color: Colors.grey.shade300,
            height: 1,
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/assistant_message.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
  });

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUser ? AppColors.primary : AppColors.surface;
    final textColor = message.isUser ? Colors.white : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: message.isUser ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, height: 1.4),
          ),
        ),
      ],
    );
  }
}

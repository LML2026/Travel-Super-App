import 'package:flutter/material.dart';

class EmptyTripCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const EmptyTripCard({
    super.key,
    required this.message,
    this.icon = Icons.event_busy,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onActionTap,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

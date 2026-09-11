import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({
    super.key,
    required this.onOpenPlanner,
  });

  final VoidCallback onOpenPlanner;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.smart_toy_outlined,
      title: 'AI Travel Planner',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate a day-by-day plan from this trip, bookings, budget and itinerary.',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onOpenPlanner,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Open AI Planner'),
          ),
        ],
      ),
    );
  }
}

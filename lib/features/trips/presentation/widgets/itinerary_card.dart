import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class ItineraryCard extends StatelessWidget {
  const ItineraryCard({
    super.key,
    required this.days,
  });

  final int days;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.event_note,
      title: 'Itinerary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(
          days,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Day ${index + 1}'),
          ),
        ),
      ),
    );
  }
}

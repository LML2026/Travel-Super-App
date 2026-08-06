import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardSection(
      icon: Icons.smart_toy_outlined,
      title: 'AI Assistant',
      child: Text('Trip-aware AI assistant actions will appear here.'),
    );
  }
}

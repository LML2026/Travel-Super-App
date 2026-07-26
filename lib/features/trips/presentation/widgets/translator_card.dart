import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class TranslatorCard extends StatelessWidget {
  const TranslatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardSection(
      icon: Icons.translate_outlined,
      title: 'Translator',
      child: Text('Voice and text translation will appear here.'),
    );
  }
}

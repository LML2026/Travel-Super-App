import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class TranslatorCard extends StatelessWidget {
  const TranslatorCard({
    super.key,
    required this.onOpenTranslator,
  });

  final VoidCallback onOpenTranslator;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.translate_outlined,
      title: 'Translator',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Travel Translator'),
        subtitle: const Text('Text, conversation mode and phrasebook.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenTranslator,
      ),
    );
  }
}

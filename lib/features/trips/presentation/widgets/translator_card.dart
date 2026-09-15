import 'package:flutter/material.dart';

import 'dashboard_section.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

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
        title: Text(context.ui('travelTranslator')),
        subtitle: Text(context.ui('translatorCardSubtitle')),
        trailing: const Icon(Icons.chevron_right),
        onTap: onOpenTranslator,
      ),
    );
  }
}

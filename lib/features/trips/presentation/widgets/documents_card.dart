import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class DocumentsCard extends StatelessWidget {
  const DocumentsCard({
    super.key,
    required this.hasDocuments,
    this.onOpenDocuments,
  });

  final bool hasDocuments;
  final VoidCallback? onOpenDocuments;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      icon: Icons.description_outlined,
      title: 'Documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasDocuments
                ? 'Travel documents are available for this trip.'
                : 'No trip documents yet. Add passport, visa, and ticket references.',
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onOpenDocuments,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(hasDocuments ? 'Manage Documents' : 'Add Documents'),
          ),
        ],
      ),
    );
  }
}

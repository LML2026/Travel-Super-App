import 'package:flutter/material.dart';

import 'dashboard_section.dart';

class DocumentsCard extends StatelessWidget {
  const DocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardSection(
      icon: Icons.description_outlined,
      title: 'Documents',
      child: Text('Passports, visas, and tickets will appear here.'),
    );
  }
}

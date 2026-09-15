import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:travel_super_app/l10n/l10n_extensions.dart';

class RecentFlightSearchesPage extends StatelessWidget {
  const RecentFlightSearchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.ui('recentSearches')),
        ),
        body: Center(
          child: Text(context.ui('signInViewRecentSearches')),
        ),
      );
    }

    final searchesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('recent_flight_searches')
        .orderBy('searchedAt', descending: true)
        .limit(20)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.ui('recentSearches')),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: searchesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Failed to load recent searches:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSubtle,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'No recent searches yet',
                    style: AppTextStyles.title,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Your flight searches will appear here.',
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final from = data['from']?.toString() ?? '';
              final to = data['to']?.toString() ?? '';
              final passengers =
                  int.tryParse(data['passengers']?.toString() ?? '') ?? 1;
              final cabinClass = data['cabinClass']?.toString() ?? 'Economy';

              final departureDate =
                  _formatDate(data['departureDate']?.toString());

              final returnDate = _formatDate(data['returnDate']?.toString());

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.navy50,
                    child: Icon(Icons.flight),
                  ),
                  title: Text(
                    '$from → $to',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    [
                      'Departure: $departureDate',
                      if (returnDate != 'Not selected') 'Return: $returnDate',
                      '$passengers passenger${passengers == 1 ? '' : 's'}',
                      cabinClass,
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: context.ui('delete'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await document.reference.delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty || value == 'null') {
      return 'Not selected';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecentFlightSearchesPage extends StatelessWidget {
  const RecentFlightSearchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recent Searches'),
        ),
        body: const Center(
          child: Text('Please sign in to view recent searches.'),
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
        title: const Text('Recent Searches'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: searchesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load recent searches:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final documents = snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No recent searches yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your flight searches will appear here.',
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: documents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data();

              final from = data['from']?.toString() ?? '';
              final to = data['to']?.toString() ?? '';
              final passengers =
                  int.tryParse(data['passengers']?.toString() ?? '') ?? 1;
              final cabinClass =
                  data['cabinClass']?.toString() ?? 'Economy';

              final departureDate =
                  _formatDate(data['departureDate']?.toString());

              final returnDate =
                  _formatDate(data['returnDate']?.toString());

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.flight),
                  ),
                  title: Text(
                    '$from → $to',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    [
                      'Departure: $departureDate',
                      if (returnDate != 'Not selected')
                        'Return: $returnDate',
                      '$passengers passenger${passengers == 1 ? '' : 's'}',
                      cabinClass,
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Delete',
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

import 'package:flutter/material.dart';
import 'flight_search_page.dart';
import '../screens/recent_flight_searches_page.dart';
import '../screens/saved_flights_page.dart';

class FlightsPage extends StatelessWidget {
  const FlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Where would you like to fly?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search and compare live flight offers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FlightSearchPage(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      child: Icon(
                        Icons.flight_takeoff,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Search Flights',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Compare routes, prices and airlines',
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recent searches'),
              subtitle: const Text(
                'View your recent flight searches',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RecentFlightSearchesPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Saved flights'),
              subtitle: const Text(
                'View flight offers saved for later',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SavedFlightsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

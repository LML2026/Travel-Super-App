import 'package:flutter/material.dart';

import '../../shared/widgets/feature_card.dart';
import '../../shared/widgets/search_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Super App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👋 Good Morning',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Where would you like to travel today?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 24),

            const SearchBox(),

            const SizedBox(height: 30),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                FeatureCard(
                  title: 'Flights',
                  icon: Icons.flight_takeoff,
                  onTap: () {},
                ),
                FeatureCard(
                  title: 'Hotels',
                  icon: Icons.hotel,
                  onTap: () {},
                ),
                FeatureCard(
                  title: 'Cars',
                  icon: Icons.directions_car,
                  onTap: () {},
                ),
                FeatureCard(
                  title: 'Maps',
                  icon: Icons.map,
                  onTap: () {},
                ),
                FeatureCard(
                  title: 'Weather',
                  icon: Icons.wb_sunny,
                  onTap: () {},
                ),
                FeatureCard(
                  title: 'AI Planner',
                  icon: Icons.smart_toy,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              '⭐ Popular Destinations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                final destinations = [
                  'Paris',
                  'Rome',
                  'Tokyo',
                  'New York',
                  'Barcelona',
                  'Dubai'
                ];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(destinations[index]),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

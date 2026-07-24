import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/feature_card.dart';
import '../../shared/widgets/search_box.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    return user?.email?.split('@')[0] ?? 'Traveler';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌍 Travel Super App',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Good Morning, ${_getUserName()} 👋',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Where would you like to travel today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Box
                  const SearchBox(),
                  const SizedBox(height: 30),

                  // Feature Cards
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

                  // Popular Destinations
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
                        ('Paris', '🇫🇷'),
                        ('Rome', '🇮🇹'),
                        ('Tokyo', '🇯🇵'),
                        ('New York', '🇺🇸'),
                        ('Barcelona', '🇪🇸'),
                        ('Dubai', '🇦🇪'),
                      ];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Text(
                            destinations[index].$2,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(destinations[index].$1),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Upcoming Trips
                  const Text(
                    '📅 Upcoming Trips',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No trips yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

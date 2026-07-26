import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/destinations.dart';
import '../../shared/widgets/destination_card.dart';
import '../../shared/widgets/empty_trip_card.dart';
import '../../shared/widgets/feature_card.dart';
import '../../shared/widgets/home_header.dart';
import '../../shared/widgets/search_box.dart';
import '../../shared/widgets/section_title.dart';

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
            HomeHeader(
              userName: _getUserName(),
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
                  const SizedBox(height: 30),

                  const Text(
                    'Popular Destinations',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: destinations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        return DestinationCard(
                          city: destination.city,
                          country: destination.country,
                          image: destination.image,
                          onTap: () {
                            context.push('/destination', extra: destination);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Upcoming Trips
                  const SectionTitle(title: '📅 Upcoming Trips'),

                  const EmptyTripCard(
                    message: 'No trips yet',
                    icon: Icons.event_busy,
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

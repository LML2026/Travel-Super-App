import 'package:flutter/material.dart';
import 'package:travel_super_app/features/trip_planner/pages/trip_planner_page.dart';
import '../flights/pages/flights_page.dart';
import '../hotels/pages/hotels_page.dart';
import '../weather/pages/weather_page.dart';
import '../home/home_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    FlightsPage(),
    HotelsPage(),
    WeatherPage(),
    TripPlannerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_outlined),
            selectedIcon: Icon(Icons.flight),
            label: 'Flights',
          ),
          NavigationDestination(
            icon: Icon(Icons.hotel_outlined),
            selectedIcon: Icon(Icons.hotel),
            label: 'Hotels',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(Icons.luggage_outlined),
            selectedIcon: Icon(Icons.luggage),
            label: 'Trips',
          ),
        ],
      ),
    );
  }
}
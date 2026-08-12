import 'package:flutter/material.dart';

void main() {
  runApp(const ItarevoApp());
}

class ItarevoApp extends StatelessWidget {
  const ItarevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITAREVO',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ITAREVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.public,
              size: 80,
            ),
            SizedBox(height: 24),
            Text(
              'ITAREVO',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Travel smarter.',
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SportsScoreTrackerApp());
}

class SportsScoreTrackerApp extends StatelessWidget {
  const SportsScoreTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Score Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E293B)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
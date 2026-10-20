import 'package:flutter/material.dart';

enum SportType {
  football(
    id: 'football',
    label: 'Football',
    icon: Icons.sports_soccer,
    accentColor: Color(0xFF10B981),
  ),
  cricket(
    id: 'cricket',
    label: 'Cricket',
    icon: Icons.sports_cricket,
    accentColor: Color(0xFF3B82F6),
  ),
  motorsport(
    id: 'motorsport',
    label: 'Formula 1',
    icon: Icons.sports_motorsports,
    accentColor: Color(0xFFEF4444),
  ),
  basketball(
    id: 'basketball',
    label: 'Basketball',
    icon: Icons.sports_basketball,
    accentColor: Color(0xFFF97316),
  ),
  americanFootball(
    id: 'american_football',
    label: 'NFL / NCAAF',
    icon: Icons.sports_football,
    accentColor: Color(0xFF8B5CF6),
  ),
  baseball(
    id: 'baseball',
    label: 'Baseball',
    icon: Icons.sports_baseball,
    accentColor: Color(0xFF06B6D4),
  ),
  hockey(
    id: 'hockey',
    label: 'Hockey',
    icon: Icons.sports_hockey,
    accentColor: Color(0xFF6366F1),
  );

  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;

  const SportType({
    required this.id,
    required this.label,
    required this.icon,
    required this.accentColor,
  });
}
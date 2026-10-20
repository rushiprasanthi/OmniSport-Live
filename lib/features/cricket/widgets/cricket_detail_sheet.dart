import 'package:flutter/material.dart';
import '../models/cricket_match_model.dart';

class CricketDetailSheet extends StatelessWidget {
  final CricketMatchModel match;

  const CricketDetailSheet({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${match.leagueName} • ${match.format.label}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${match.teamA} vs ${match.teamB}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              match.venue,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const Divider(height: 28),

            // Run Rate & Toss Summary
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (match.currentRunRate != null)
                  _MetricChip(
                    label: 'Current Run Rate (CRR)',
                    value: match.currentRunRate!.toStringAsFixed(2),
                  ),
                if (match.requiredRunRate != null)
                  _MetricChip(
                    label: 'Required Run Rate (RRR)',
                    value: match.requiredRunRate!.toStringAsFixed(2),
                  ),
                _MetricChip(
                  label: 'Format',
                  value: match.format.label,
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Innings Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...match.innings.map(
              (inn) => Card(
                elevation: 0,
                color: const Color(0xFFF1F5F9),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    '${inn.teamName} (Innings ${inn.inningsNumber})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    inn.isCurrent ? 'Currently Batting' : 'Completed Innings',
                  ),
                  trailing: Text(
                    inn.formattedScore,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            if (match.activeBatters.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Batters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              ...match.activeBatters.map(
                (b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('🏏 $b', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],

            if (match.activeBowlers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Key Bowlers (O-M-R-W)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 6),
              ...match.activeBowlers.map(
                (b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('⚾ $b', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],

            const Divider(height: 28),
            Text(
              'Toss: ${match.tossSummary}',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'Status: ${match.matchNote}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
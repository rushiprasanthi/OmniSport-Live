import 'package:flutter/material.dart';

import '../../core/models/standings_model.dart';

class StandingsView extends StatelessWidget {
  final StandingsTable? standings;

  const StandingsView({super.key, this.standings});

  @override
  Widget build(BuildContext context) {
    if (standings == null) {
      return const Center(
        child: Text('No standings available yet.'),
      );
    }

    final rows = standings!.rows;

    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                standings!.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                standings!.subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = rows[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: row.rank <= 3 ? Colors.amber.shade100 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${row.rank}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (row.logoUrl != null && row.logoUrl!.isNotEmpty)
                      ClipOval(
                        child: Image.network(
                          row.logoUrl!,
                          width: 32,
                          height: 32,
                          errorBuilder: (_, __, ___) => const Icon(Icons.sports),
                        ),
                      )
                    else
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.sports, size: 18),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.entityName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (row.entitySubtitle != null && row.entitySubtitle!.isNotEmpty)
                            Text(
                              row.entitySubtitle!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...row.cells.asMap().entries.map((entry) {
                      final cellIndex = entry.key;
                      final cell = entry.value;
                      final isPointsCell = cellIndex == row.cells.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          cell,
                          style: TextStyle(
                            fontWeight: isPointsCell ? FontWeight.bold : FontWeight.w600,
                            color: isPointsCell ? Colors.blueAccent : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(width: 8),
                    Text(
                      row.highlightPoints,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


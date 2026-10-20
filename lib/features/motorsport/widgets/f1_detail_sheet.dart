import 'package:flutter/material.dart';
import '../models/f1_race_model.dart';

class F1DetailSheet extends StatelessWidget {
  final F1RaceModel race;

  const F1DetailSheet({
    super.key,
    required this.race,
  });

  static void show(BuildContext context, F1RaceModel race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => F1DetailSheet(race: race),
    );
  }

  Color _getPositionBadgeColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.blueGrey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ROUND ${race.round} • ${race.season}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    race.raceName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${race.circuitName} • ${race.locality}, ${race.country}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color(0xFF1E293B),
                labelColor: Color(0xFF1E293B),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: [
                  Tab(text: 'CLASSIFICATION'),
                  Tab(text: 'SCHEDULE'),
                  Tab(text: 'CIRCUIT INFO'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildClassificationTab(),
                  _buildScheduleTab(),
                  _buildCircuitInfoTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassificationTab() {
    if (race.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_score, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'No race classification available yet.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Results appear once the session begins.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFF1F5F9),
          child: const Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  'POS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'DRIVER / TEAM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Text(
                  'TIME / GAP',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  'PTS',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Drivers List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: race.results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final driver = race.results[index];
              final hasFastestLap = race.fastestLapDriver == driver.driverCode ||
                  race.fastestLapDriver == driver.driverName;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    // Position Badge
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getPositionBadgeColor(driver.position),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${driver.position}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: driver.position <= 3
                              ? const Color(0xFF0F172A)
                              : Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Driver and Team Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  driver.driverName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (hasFastestLap) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9333EA),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'FL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${driver.constructorName} • Grid P${driver.gridPosition}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Time / Behind
                    SizedBox(
                      width: 80,
                      child: Text(
                        driver.timeOrStatus,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),

                    // Points Awarded
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${driver.points}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
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

  Widget _buildScheduleTab() {
    if (race.sessions.isEmpty) {
      return Center(
        child: Text(
          'No session schedule published for this race.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: race.sessions.length,
      itemBuilder: (context, index) {
        final session = race.sessions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.dateString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.isCompleted
                        ? Colors.grey.shade200
                        : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session.isCompleted ? 'COMPLETED' : session.timeString,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: session.isCompleted
                          ? Colors.grey.shade700
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircuitInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Circuit Specifications',
          items: {
            'Circuit Name': race.circuitName,
            'Locality': race.locality,
            'Country': race.country,
            'Race Distance': '${race.totalLaps} Laps',
          },
        ),
        const SizedBox(height: 12),
        if (race.fastestLapDriver != null) ...[
          _buildInfoCard(
            title: 'Session Highlights',
            items: {
              'Fastest Lap': race.fastestLapDriver!,
              'Event Status': race.statusDetail,
            },
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Map<String, String> items,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const Divider(height: 20),
            ...items.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
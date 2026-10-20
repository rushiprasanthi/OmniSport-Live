import 'package:flutter/material.dart';
import '../models/f1_race_model.dart';
import 'f1_detail_sheet.dart';

class F1RaceCard extends StatelessWidget {
  final F1RaceModel race;

  const F1RaceCard({
    super.key,
    required this.race,
  });

  Color _getPositionBadgeColor(int position) {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.blueGrey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = race.state == 'in';
    final hasResults = race.results.isNotEmpty;
    final topThree = hasResults ? race.results.take(3).toList() : <F1DriverResult>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLive
            ? const BorderSide(color: Colors.redAccent, width: 1.8)
            : BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => F1DetailSheet.show(context, race),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Round, Season, and Live/State Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ROUND ${race.round}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'F1 ${race.season}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive
                          ? Colors.red.withValues(alpha: 0.12)
                          : race.state == 'post'
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLive) ...[
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                        Text(
                          isLive
                              ? 'LIVE  ${race.statusDetail}'
                              : race.statusDetail.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: isLive
                                ? Colors.red.shade700
                                : race.state == 'post'
                                    ? Colors.green.shade700
                                    : Colors.blueGrey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Grand Prix Title
              Text(
                race.raceName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),

              // Circuit and Country
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${race.circuitName}, ${race.locality}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Classification Podium or Upcoming Schedule Preview
              if (topThree.isNotEmpty) ...[
                Text(
                  race.state == 'post' ? 'PODIUM FINISHERS' : 'CURRENT LEADERS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: topThree.map((driver) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _getPositionBadgeColor(driver.position),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${driver.position}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: driver.position <= 3
                                    ? const Color(0xFF1E293B)
                                    : Colors.blueGrey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1E293B),
                                ),
                                children: [
                                  TextSpan(
                                    text: '${driver.driverName} ',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: '(${driver.constructorName})',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            driver.timeOrStatus,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                // Next Session Information for Scheduled/Upcoming Races
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: Color(0xFF334155),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          race.dateFormatted,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Text(
                        '${race.totalLaps} LAPS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),
              // Footer Action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Full Weekend & Grid',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
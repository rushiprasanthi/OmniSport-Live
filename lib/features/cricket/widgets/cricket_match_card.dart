import 'package:flutter/material.dart';
import '../models/cricket_match_model.dart';

class CricketMatchCard extends StatelessWidget {
  final CricketMatchModel match;
  final VoidCallback onTap;

  const CricketMatchCard({
    super.key,
    required this.match,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLive = match.isLive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isLive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLive
            ? const BorderSide(color: Colors.redAccent, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Series + Format Badge + Live Status
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      match.format.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.leagueName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLive
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.blueGrey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLive
                          ? '● LIVE  ${match.statusDetail}'
                          : match.statusDetail,
                      style: TextStyle(
                        fontSize: 11,
                        color: isLive ? Colors.red : Colors.blueGrey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Team A Innings Row
              _TeamInningsRow(
                teamName: match.teamA,
                shortCode: match.teamAShort,
                scoreText: match.scoreForTeam(match.teamAShort, match.teamA),
                isBatting: match.innings.any(
                  (i) => i.shortTeamName == match.teamAShort && i.isCurrent,
                ),
              ),
              const SizedBox(height: 10),

              // Team B Innings Row
              _TeamInningsRow(
                teamName: match.teamB,
                shortCode: match.teamBShort,
                scoreText: match.scoreForTeam(match.teamBShort, match.teamB),
                isBatting: match.innings.any(
                  (i) => i.shortTeamName == match.teamBShort && i.isCurrent,
                ),
              ),

              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.matchNote,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLive
                            ? Colors.red.shade700
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🪙 ${match.tossSummary}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamInningsRow extends StatelessWidget {
  final String teamName;
  final String shortCode;
  final String scoreText;
  final bool isBatting;

  const _TeamInningsRow({
    required this.teamName,
    required this.shortCode,
    required this.scoreText,
    required this.isBatting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isBatting
                    ? Colors.blueAccent.withValues(alpha: 0.15)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                shortCode,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isBatting ? Colors.blue.shade900 : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              teamName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBatting ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (isBatting) ...[
              const SizedBox(width: 6),
              const Icon(Icons.sports_cricket, size: 14, color: Colors.redAccent),
            ],
          ],
        ),
        Flexible(
          child: Text(
            scoreText,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isBatting ? const Color(0xFF0F172A) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../models/football_match_model.dart';

class FootballMatchCard extends StatelessWidget {
  final FootballMatchModel match;
  final VoidCallback onTap;

  const FootballMatchCard({
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Match Header (League & Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLive
                          ? '● LIVE  ${match.statusDetail}'
                          : match.statusDetail,
                      style: TextStyle(
                        fontSize: 12,
                        color: isLive ? Colors.red : Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Team & Score Row
              Row(
                children: [
                  // Home Team
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _TeamCrest(logoUrl: match.homeLogo),
                        const SizedBox(height: 6),
                        Text(
                          match.homeTeam,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scores
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        match.state == 'pre'
                            ? 'VS'
                            : '${match.homeScore} - ${match.awayScore}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Away Team
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _TeamCrest(logoUrl: match.awayLogo),
                        const SizedBox(height: 6),
                        Text(
                          match.awayTeam,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (match.keyEvents.isNotEmpty || match.venue != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (match.venue != null)
                      Expanded(
                        child: Text(
                          '📍 ${match.venue}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    const Text(
                      'Match Centre & Lineups →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamCrest extends StatelessWidget {
  final String? logoUrl;

  const _TeamCrest({this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl == null || logoUrl!.isEmpty) {
      return const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFE2E8F0),
        child: Icon(Icons.shield_outlined, size: 18, color: Color(0xFF475569)),
      );
    }

    return Image.network(
      logoUrl!,
      width: 32,
      height: 32,
      errorBuilder: (_, __, ___) => const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFE2E8F0),
        child: Icon(Icons.shield_outlined, size: 18, color: Color(0xFF475569)),
      ),
    );
  }
}
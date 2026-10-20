import 'package:flutter/material.dart';
import '../models/football_match_model.dart';
import '../repositories/football_repository.dart';

class FootballDetailSheet extends StatefulWidget {
  final FootballMatchModel match;
  final FootballRepository repository;

  const FootballDetailSheet({
    super.key,
    required this.match,
    required this.repository,
  });

  @override
  State<FootballDetailSheet> createState() => _FootballDetailSheetState();
}

class _FootballDetailSheetState extends State<FootballDetailSheet> {
  late Future<FootballMatchModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.repository.fetchMatchSummary(widget.match);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return FutureBuilder<FootballMatchModel>(
          future: _detailFuture,
          builder: (context, snapshot) {
            final match = snapshot.data ?? widget.match;

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
                  match.leagueName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${match.homeTeam}  ${match.homeScore} - ${match.awayScore}  ${match.awayTeam}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${match.statusDetail}${match.venue != null ? ' • ${match.venue}' : ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const Divider(height: 28),

                // Formations & Possession
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatPill(
                      label: '${match.homeTeam} Formation',
                      value: match.homeFormation ?? '4-3-3',
                    ),
                    if (match.homePossession != null &&
                        match.awayPossession != null)
                      _StatPill(
                        label: 'Possession',
                        value:
                            '${match.homePossession} / ${match.awayPossession}',
                      ),
                    _StatPill(
                      label: '${match.awayTeam} Formation',
                      value: match.awayFormation ?? '4-2-3-1',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Key Match Events (Goals & Cards)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                if (match.keyEvents.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No key goals or disciplinary cards recorded yet.',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  )
                else
                  ...match.keyEvents.map(
                    (ev) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: ev.type == 'Goal'
                            ? Colors.green.shade100
                            : (ev.type == 'Red Card'
                                ? Colors.red.shade100
                                : Colors.amber.shade100),
                        child: Icon(
                          ev.type == 'Goal'
                              ? Icons.sports_soccer
                              : Icons.style,
                          size: 16,
                          color: ev.type == 'Goal'
                              ? Colors.green.shade800
                              : (ev.type == 'Red Card'
                                  ? Colors.red.shade800
                                  : Colors.orange.shade800),
                        ),
                      ),
                      title: Text(
                        '${ev.clock}  ${ev.playerName} (${ev.type})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(ev.teamName),
                    ),
                  ),

                const Divider(height: 28),
                const Text(
                  'Squad Lineups',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (match.homeLineup.isEmpty && match.awayLineup.isEmpty)
                  const Text(
                    'Confirmed starting XIs will appear closer to kick-off.',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _LineupColumn(
                          teamName: match.homeTeam,
                          players: match.homeLineup,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LineupColumn(
                          teamName: match.awayTeam,
                          players: match.awayLineup,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _LineupColumn extends StatelessWidget {
  final String teamName;
  final List<FootballPlayerLineup> players;

  const _LineupColumn({required this.teamName, required this.players});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        ...players.map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(
              '#${p.jersey} ${p.name} ${p.position.isNotEmpty ? '(${p.position})' : ''}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
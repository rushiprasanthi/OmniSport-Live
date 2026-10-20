import 'package:flutter/material.dart';

import '../core/models/sport_league.dart';
import '../core/models/sport_type.dart';
import '../core/state/multi_sport_controller.dart';
import '../features/cricket/models/cricket_match_model.dart';
import '../features/cricket/widgets/cricket_detail_sheet.dart';
import '../features/cricket/widgets/cricket_match_card.dart';
import '../features/football/models/football_match_model.dart';
import '../features/football/widgets/football_detail_sheet.dart';
import '../features/football/widgets/football_match_card.dart';
import '../features/motorsport/models/f1_race_model.dart';
import '../features/motorsport/widgets/f1_race_card.dart';
import '../models/match_model.dart';
import 'widgets/standings_view.dart';
import 'widgets/sport_selector_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MultiSportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MultiSportController();
    _controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final leagues = SportLeagueCatalog.forSport(_controller.selectedSport);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Live Sports Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Demo',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Switch.adaptive(
                value: _controller.includeDemoLive,
                onChanged: (_) => _controller.toggleDemoLive(),
                activeColor: Colors.green,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Manual Refresh',
                onPressed: () => _controller.refresh(),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              SportSelectorBar(
                selectedSport: _controller.selectedSport,
                onSelected: _controller.selectSport,
              ),
              Container(
                width: double.infinity,
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: leagues.map((league) {
                      final selected = _controller.selectedLeague.id == league.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(league.title),
                          selected: selected,
                          onSelected: (_) => _controller.selectLeague(league),
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: const Color(0xFF334155),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Fixtures'),
                        selected: !_controller.showStandings,
                        onSelected: (_) => _controller.toggleViewMode(false),
                        selectedColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: !_controller.showStandings ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        showCheckmark: false,
                      ),
                    ),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Standings'),
                        selected: _controller.showStandings,
                        onSelected: (_) => _controller.toggleViewMode(true),
                        selectedColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: _controller.showStandings ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        showCheckmark: false,
                      ),
                    ),
                  ],
                ),
              ),
              if (_controller.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_controller.isLoading && _controller.events.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_controller.showStandings)
                Expanded(
                  child: StandingsView(standings: _controller.standings),
                )
              else
                Expanded(
                  child: _buildEventList(),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    final events = _controller.events;

    if (events.isEmpty) {
      return const Center(
        child: Text('No matches scheduled right now.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        switch (event.sportType) {
          case SportType.football:
            final match = event as FootballMatchModel;
            return FootballMatchCard(
              match: match,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => FootballDetailSheet(
                    match: match,
                    repository: _controller.footballRepository,
                  ),
                );
              },
            );
          case SportType.cricket:
            final match = event as CricketMatchModel;
            return CricketMatchCard(
              match: match,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CricketDetailSheet(match: match),
                );
              },
            );
          case SportType.motorsport:
            final race = event as F1RaceModel;
            return F1RaceCard(race: race);
          case SportType.basketball:
          case SportType.americanFootball:
          case SportType.baseball:
          case SportType.hockey:
            final match = event as MatchModel;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(match.homeTeam),
                subtitle: Text('${match.awayTeam} • ${match.statusDetail}'),
                trailing: Text(
                  match.state == 'pre' ? 'VS' : '${match.homeScore} - ${match.awayScore}',
                ),
              ),
            );
        }
      },
    );
  }
}
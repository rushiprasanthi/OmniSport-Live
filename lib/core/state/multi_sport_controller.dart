import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../features/cricket/repositories/cricket_repository.dart';
import '../../features/football/repositories/football_repository.dart';
import '../../features/motorsport/repositories/f1_repository.dart';
import '../../features/other_sports/team_sport_repository.dart';
import '../../models/match_model.dart';
import '../models/sport_event.dart';
import '../models/sport_league.dart';
import '../models/sport_type.dart';
import '../models/standings_model.dart';

class MultiSportController extends ChangeNotifier {
  MultiSportController() {
    selectedLeague = SportLeagueCatalog.forSport(selectedSport).first;
    refresh();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      refresh(isBackground: true);
    });
  }

  final FootballRepository footballRepository = FootballRepository();
  final CricketRepository cricketRepository = CricketRepository();
  final F1Repository f1Repository = F1Repository();
  final TeamSportRepository teamSportRepository = TeamSportRepository();

  SportType selectedSport = SportType.football;
  late SportLeague selectedLeague;
  bool showStandings = false;
  bool includeDemoLive = true;
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  List<SportEvent> events = <SportEvent>[];
  StandingsTable? standings;
  Timer? _pollingTimer;

  Future<void> refresh({bool isBackground = false}) async {
    if (!isBackground) {
      isLoading = true;
      isRefreshing = false;
    } else if (events.isNotEmpty) {
      isRefreshing = true;
    }
    errorMessage = null;
    notifyListeners();

    try {
      final currentLeague = selectedLeague;
      final nextEvents = await _fetchScoreboardForLeague(currentLeague);
      if (selectedLeague.id == currentLeague.id &&
          selectedLeague.path == currentLeague.path) {
        events = nextEvents;
      }
      standings = await _fetchStandingsForLeague(currentLeague);
    } catch (e) {
      if (events.isNotEmpty) {
        errorMessage = 'Background refresh warning: ${e.toString()}';
      } else {
        errorMessage = e.toString();
      }
    } finally {
      if (!isBackground) {
        isLoading = false;
      }
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<List<SportEvent>> _fetchScoreboardForLeague(SportLeague league) async {
    switch (league.sportType) {
      case SportType.football:
        final matches = await footballRepository.fetchScoreboard(
          league: league,
          includeDemoLive: includeDemoLive,
        );
        return matches.cast<SportEvent>();
      case SportType.cricket:
        final matches = await cricketRepository.fetchScoreboard(
          league: league,
          includeDemoLive: includeDemoLive,
        );
        return matches.cast<SportEvent>();
      case SportType.motorsport:
        final races = await f1Repository.fetchScoreboard(
          league: league,
          includeDemoLive: includeDemoLive,
        );
        return races.cast<SportEvent>();
      case SportType.basketball:
      case SportType.americanFootball:
      case SportType.baseball:
      case SportType.hockey:
        final teamMatches = await teamSportRepository.fetchScoreboard(
          league: league,
          includeDemoLive: includeDemoLive,
        );
        return teamMatches.cast<SportEvent>();
    }
  }

  Future<StandingsTable?> _fetchStandingsForLeague(SportLeague league) async {
    switch (league.sportType) {
      case SportType.football:
        return footballRepository.fetchStandings(league: league);
      case SportType.cricket:
        return cricketRepository.fetchStandings(league: league);
      case SportType.motorsport:
        return f1Repository.fetchStandings(league: league);
      case SportType.basketball:
      case SportType.americanFootball:
      case SportType.baseball:
      case SportType.hockey:
        return teamSportRepository.fetchStandings(league: league);
    }
  }

  void selectSport(SportType sportType) {
    if (sportType == selectedSport) {
      return;
    }
    selectedSport = sportType;
    final nextLeagues = SportLeagueCatalog.forSport(sportType);
    if (nextLeagues.isNotEmpty) {
      selectedLeague = nextLeagues.first;
    }
    refresh();
  }

  void selectLeague(SportLeague league) {
    selectedLeague = league;
    refresh();
  }

  void toggleViewMode(bool value) {
    showStandings = value;
    notifyListeners();
    refresh();
  }

  void toggleDemoLive() {
    includeDemoLive = !includeDemoLive;
    refresh();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    footballRepository.close();
    cricketRepository.close();
    f1Repository.close();
    teamSportRepository.close();
    super.dispose();
  }
}


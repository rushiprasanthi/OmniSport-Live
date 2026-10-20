import '../models/sport_event.dart';
import '../models/sport_league.dart';
import '../models/standings_model.dart';

abstract class SportRepository<T extends SportEvent> {
  Future<List<T>> fetchScoreboard({
    required SportLeague league,
    required bool includeDemoLive,
  });

  Future<StandingsTable> fetchStandings({
    required SportLeague league,
  });
}
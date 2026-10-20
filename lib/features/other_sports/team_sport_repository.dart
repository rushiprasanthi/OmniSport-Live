import '../../core/models/sport_league.dart';
import '../../core/models/standings_model.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/sport_repository.dart';
import '../../models/match_model.dart';
import '../../services/api_service.dart';

class TeamSportRepository implements SportRepository<MatchModel> {
  final ApiClient _apiClient;

  TeamSportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void close() => _apiClient.close();

  @override
  Future<List<MatchModel>> fetchScoreboard({
    required SportLeague league,
    required bool includeDemoLive,
  }) async {
    final url = 'https://site.api.espn.com/apis/site/v2/sports/${league.path}/scoreboard';
    try {
      final decoded = await _apiClient.getJson(url);
      final events = decoded['events'] as List<dynamic>? ?? [];
      final matches = events
          .whereType<Map<String, dynamic>>()
          .map(
            (event) => MatchModel.fromJson(
              event,
              league.title,
              sportType: league.sportType,
              leagueId: league.id,
            ),
          )
          .toList();

      if (includeDemoLive) {
        return [ApiService.buildDemoLiveMatch(sportType: league.sportType), ...matches];
      }
      return matches;
    } catch (_) {
      if (includeDemoLive) {
        return [ApiService.buildDemoLiveMatch(sportType: league.sportType)];
      }
      return const <MatchModel>[];
    }
  }

  @override
  Future<StandingsTable> fetchStandings({required SportLeague league}) async {
    final url = 'https://site.api.espn.com/apis/v2/sports/${league.path}/standings';
    try {
      final decoded = await _apiClient.getJson(url);
      final children = decoded['children'] as List<dynamic>? ?? [];
      final standingsMap = children.isNotEmpty
          ? children.first as Map<String, dynamic>
          : decoded;
      final standings = standingsMap['standings'] as Map<String, dynamic>? ?? {};
      final entries = standings['entries'] as List<dynamic>? ?? [];

      if (entries.isNotEmpty) {
        final rows = entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          final team = item['team'] as Map<String, dynamic>? ?? {};
          final stats = item['stats'] as List<dynamic>? ?? [];
          String statValue(String name) {
            for (final stat in stats) {
              if (stat is Map<String, dynamic> &&
                  (stat['name'] == name || stat['abbreviation'] == name)) {
                return stat['displayValue']?.toString() ??
                    stat['value']?.toString() ??
                    '0';
              }
            }
            return '0';
          }

          return StandingsRow(
            rank: index + 1,
            entityName: team['shortDisplayName']?.toString() ??
                team['displayName']?.toString() ??
                'Team',
            logoUrl: ((team['logos'] as List<dynamic>? ?? []).isNotEmpty
                    ? (team['logos'] as List<dynamic>).first as Map<String, dynamic>? ?? {}
                    : {})['href']
                ?.toString(),
            cells: [
              statValue('gamesPlayed'),
              statValue('wins'),
              statValue('losses'),
              statValue('winPct'),
            ],
            highlightPoints: statValue('points'),
          );
        }).toList();

        return StandingsTable(
          title: league.title,
          subtitle: 'League Standings',
          columns: const ['GP', 'W', 'L', 'PCT'],
          rows: rows,
        );
      }
    } catch (_) {
      // Use fallback below.
    }

    return StandingsTable(
      title: league.title,
      subtitle: 'Standings Snapshot',
      columns: const ['GP', 'W', 'L', 'PCT'],
      rows: const [
        StandingsRow(
          rank: 1,
          entityName: 'Home Team',
          cells: ['10', '8', '2', '.800'],
          highlightPoints: '8',
        ),
        StandingsRow(
          rank: 2,
          entityName: 'Rival Club',
          cells: ['10', '7', '3', '.700'],
          highlightPoints: '7',
        ),
      ],
    );
  }
}


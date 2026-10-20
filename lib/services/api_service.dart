import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/models/sport_type.dart';
import '../models/match_model.dart';

class ApiService {
  static const String baseUrl = 'https://site.api.espn.com/apis/site/v2/sports';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<MatchModel>> fetchMatches({
    required String leaguePath,
    required String leagueTitle,
    SportType sportType = SportType.football,
    bool includeDemoLive = true,
  }) async {
    final Uri url = Uri.parse('$baseUrl/$leaguePath/scoreboard');

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
        final List<dynamic>? events = decodedData['events'] as List<dynamic>?;

        List<MatchModel> matches = <MatchModel>[];
        if (events != null && events.isNotEmpty) {
          matches = events
              .whereType<Map<String, dynamic>>()
              .map(
                (event) => MatchModel.fromJson(
                  event,
                  leagueTitle,
                  sportType: sportType,
                ),
              )
              .toList();
        }

        if (includeDemoLive) {
          matches.insert(0, buildDemoLiveMatch(sportType: sportType));
        }

        return matches;
      }
      throw Exception('Server returned HTTP ${response.statusCode}');
    } catch (e) {
      if (includeDemoLive) {
        return [buildDemoLiveMatch(sportType: sportType)];
      }
      throw Exception('Failed to load matches: $e');
    }
  }

  static MatchModel buildDemoLiveMatch({
    SportType sportType = SportType.football,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final fakeHomeScore = (currentTime.second % 4 + 1).toString();
    final fakeAwayScore = (currentTime.second % 3).toString();

    return MatchModel(
      id: 'demo_live_999',
      leagueName: 'Demo Evaluation League',
      homeTeam: 'LBRCE Titans',
      awayTeam: 'Rival College',
      homeScore: fakeHomeScore,
      awayScore: fakeAwayScore,
      statusDetail: "75'",
      state: 'in',
      homeLogo:
          'https://a.espncdn.com/i/teamlogos/soccer/500/default-team-logo-500.png',
      awayLogo:
          'https://a.espncdn.com/i/teamlogos/soccer/500/default-team-logo-500.png',
      sportType: sportType,
      venue: 'LBRCE Main Stadium',
    );
  }

  void close() => _client.close();
}

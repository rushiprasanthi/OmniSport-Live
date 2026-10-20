import '../../../core/models/sport_league.dart';
import '../../../core/models/standings_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/repositories/sport_repository.dart';
import '../models/cricket_match_model.dart';

class CricketRepository implements SportRepository<CricketMatchModel> {
  static const String _baseUrl = 'https://site.api.espn.com/apis/site/v2/sports';
  final ApiClient _apiClient;

  CricketRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  void close() => _apiClient.close();

  @override
  Future<List<CricketMatchModel>> fetchScoreboard({
    required SportLeague league,
    required bool includeDemoLive,
  }) async {
    final format = _formatForLeague(league);
    List<CricketMatchModel> matches = <CricketMatchModel>[];

    try {
      final url = '$_baseUrl/${league.path}/scoreboard';
      final decoded = await _apiClient.getJson(url);
      final events = decoded['events'] as List<dynamic>? ?? [];
      matches = events
          .whereType<Map<String, dynamic>>()
          .map((e) => CricketMatchModel.fromEspnJson(e, league.title, format))
          .toList();
    } catch (_) {
      // Fallback to structured fixtures when public ESPN cricket league ID is off-season.
    }

    if (matches.isEmpty) {
      matches = _curatedMatchesForFormat(league, format);
    }

    if (includeDemoLive) {
      matches.insert(0, _buildDynamicLiveCricketMatch(league, format));
    }

    return matches;
  }

  CricketFormat _formatForLeague(SportLeague league) {
    if (league.id.contains('test')) return CricketFormat.test;
    if (league.id.contains('odi')) return CricketFormat.odi;
    return CricketFormat.t20;
  }

  CricketMatchModel _buildDynamicLiveCricketMatch(
    SportLeague league,
    CricketFormat format,
  ) {
    final sec = DateTime.now().second;
    final dynamicRuns = 164 + (sec % 18);
    final dynamicBall = sec % 6;

    String matchNote;
    String statusDetail;
    String australiaOvers;
    int australiaRuns;

    if (format == CricketFormat.test) {
      matchNote = 'India trail by ${312 - dynamicRuns} runs with 7 wickets remaining in 1st Innings';
      statusDetail = 'Day 2 • Session 3 (${17}.$dynamicBall Ov)';
      australiaRuns = 312;
      australiaOvers = '88.4';
    } else if (format == CricketFormat.odi) {
      matchNote = 'India need ${287 - dynamicRuns} runs from ${(32 * 6) + (6 - dynamicBall)} balls';
      statusDetail = '17.$dynamicBall/50 Ov • CRR 9.48';
      australiaRuns = 286;
      australiaOvers = '50.0';
    } else {
      matchNote = 'India need ${189 - dynamicRuns} runs from ${18 - dynamicBall} balls';
      statusDetail = '17.$dynamicBall Ov • CRR 9.48';
      australiaRuns = 188;
      australiaOvers = '20.0';
    }

    return CricketMatchModel(
      id: 'cricket_live_demo_${league.id}',
      leagueName: league.title,
      format: format,
      teamA: 'India',
      teamB: 'Australia',
      teamAShort: 'IND',
      teamBShort: 'AUS',
      innings: [
        CricketInnings(
          teamName: 'Australia',
          shortTeamName: 'AUS',
          inningsNumber: 1,
          runs: australiaRuns,
          wickets: format == CricketFormat.test ? 10 : 6,
          overs: australiaOvers,
        ),
        CricketInnings(
          teamName: 'India',
          shortTeamName: 'IND',
          inningsNumber: 1,
          runs: dynamicRuns,
          wickets: 3,
          overs: '17.$dynamicBall',
          isCurrent: true,
        ),
      ],
      currentRunRate: 9.48,
      requiredRunRate: 8.72,
      tossSummary: 'India won the toss and elected to field first',
      matchNote: matchNote,
      statusDetail: statusDetail,
      state: 'in',
      venue: 'Rajiv Gandhi International Stadium, Hyderabad',
      activeBatters: [
        'S. Yadav*  68 (39b, 6x4, 4x6)',
        'H. Pandya   24 (14b, 2x4, 1x6)',
      ],
      activeBowlers: [
        'P. Cummins  3.$dynamicBall-0-31-1',
        'M. Starc    3.0-0-29-1',
      ],
    );
  }

  List<CricketMatchModel> _curatedMatchesForFormat(
    SportLeague league,
    CricketFormat format,
  ) {
    if (format == CricketFormat.test) {
      return [
        CricketMatchModel(
          id: 'test_eng_nz_1',
          leagueName: league.title,
          format: CricketFormat.test,
          teamA: 'England',
          teamB: 'New Zealand',
          teamAShort: 'ENG',
          teamBShort: 'NZ',
          innings: const [
            CricketInnings(
              teamName: 'England',
              shortTeamName: 'ENG',
              inningsNumber: 1,
              runs: 375,
              wickets: 10,
              overs: '78.2',
            ),
            CricketInnings(
              teamName: 'New Zealand',
              shortTeamName: 'NZ',
              inningsNumber: 1,
              runs: 348,
              wickets: 10,
              overs: '96.1',
            ),
            CricketInnings(
              teamName: 'England',
              shortTeamName: 'ENG',
              inningsNumber: 2,
              runs: 264,
              wickets: 5,
              overs: '54.0',
              isDeclared: true,
            ),
            CricketInnings(
              teamName: 'New Zealand',
              shortTeamName: 'NZ',
              inningsNumber: 2,
              runs: 210,
              wickets: 10,
              overs: '69.4',
            ),
          ],
          tossSummary: 'England won the toss and elected to bat',
          matchNote: 'England won by 81 runs',
          statusDetail: 'Result • Day 4',
          state: 'post',
          venue: 'Lord\'s Cricket Ground, London',
          activeBatters: const ['J. Root  114 (148b)', 'H. Brook  78 (91b)'],
          activeBowlers: const ['G. Atkinson  5/62 (18.4 ov)'],
        ),
      ];
    }

    if (format == CricketFormat.odi) {
      return [
        CricketMatchModel(
          id: 'odi_sa_pak_1',
          leagueName: league.title,
          format: CricketFormat.odi,
          teamA: 'South Africa',
          teamB: 'Pakistan',
          teamAShort: 'SA',
          teamBShort: 'PAK',
          innings: const [
            CricketInnings(
              teamName: 'South Africa',
              shortTeamName: 'SA',
              inningsNumber: 1,
              runs: 304,
              wickets: 7,
              overs: '50.0',
            ),
            CricketInnings(
              teamName: 'Pakistan',
              shortTeamName: 'PAK',
              inningsNumber: 1,
              runs: 291,
              wickets: 9,
              overs: '50.0',
            ),
          ],
          currentRunRate: 5.82,
          tossSummary: 'South Africa won the toss and elected to bat',
          matchNote: 'South Africa won by 13 runs',
          statusDetail: 'Completed • 50 Overs',
          state: 'post',
          venue: 'Wanderers Stadium, Johannesburg',
          activeBatters: const ['H. Klaasen  97 (74b)', 'B. Azam  84 (96b)'],
          activeBowlers: const ['K. Rabada  10.0-1-48-3'],
        ),
      ];
    }

    return [
      CricketMatchModel(
        id: 't20_srh_csk_1',
        leagueName: league.title,
        format: CricketFormat.t20,
        teamA: 'Sunrisers Hyderabad',
        teamB: 'Chennai Super Kings',
        teamAShort: 'SRH',
        teamBShort: 'CSK',
        innings: const [
          CricketInnings(
            teamName: 'Chennai Super Kings',
            shortTeamName: 'CSK',
            inningsNumber: 1,
            runs: 176,
            wickets: 6,
            overs: '20.0',
          ),
          CricketInnings(
            teamName: 'Sunrisers Hyderabad',
            shortTeamName: 'SRH',
            inningsNumber: 1,
            runs: 180,
            wickets: 4,
            overs: '18.3',
          ),
        ],
        currentRunRate: 9.72,
        tossSummary: 'Sunrisers Hyderabad won the toss and elected to field',
        matchNote: 'Sunrisers Hyderabad won by 6 wickets (9 balls remaining)',
        statusDetail: 'Result • T20',
        state: 'post',
        venue: 'Uppal Stadium, Hyderabad',
        activeBatters: const [
          'T. Head  64 (36b, 7x4, 3x6)',
          'Abhishek Sharma  42 (21b, 4x4, 3x6)',
        ],
        activeBowlers: const ['P. Cummins  4.0-0-29-2'],
      ),
    ];
  }

  @override
  Future<StandingsTable> fetchStandings({required SportLeague league}) async {
    if (league.id == 'ipl') {
      return const StandingsTable(
        title: 'IPL Points Table',
        subtitle: 'T20 Franchise Standings & Net Run Rate',
        columns: ['M', 'W', 'L', 'NRR'],
        rows: [
          StandingsRow(
            rank: 1,
            entityName: 'Sunrisers Hyderabad',
            entitySubtitle: 'Qualified',
            cells: ['14', '10', '4', '+0.914'],
            highlightPoints: '20',
          ),
          StandingsRow(
            rank: 2,
            entityName: 'Chennai Super Kings',
            entitySubtitle: 'Qualified',
            cells: ['14', '9', '5', '+0.683'],
            highlightPoints: '18',
          ),
          StandingsRow(
            rank: 3,
            entityName: 'Rajasthan Royals',
            entitySubtitle: 'Qualified',
            cells: ['14', '8', '5', '+0.273'],
            highlightPoints: '17',
          ),
        ],
      );
    }

    return StandingsTable(
      title: league.title,
      subtitle: 'Recent Form',
      columns: const ['M', 'W', 'L', 'PTS'],
      rows: const [
        StandingsRow(
          rank: 1,
          entityName: 'India',
          cells: ['8', '6', '2', '12'],
          highlightPoints: '12',
        ),
        StandingsRow(
          rank: 2,
          entityName: 'Australia',
          cells: ['8', '5', '3', '10'],
          highlightPoints: '10',
        ),
      ],
    );
  }
}
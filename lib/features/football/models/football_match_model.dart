import '../../../core/models/sport_type.dart';
import '../../../models/match_model.dart';

class FootballKeyEvent {
  final String clock;
  final String type; // 'Goal', 'Yellow Card', 'Red Card', 'Substitution'
  final String playerName;
  final String teamName;
  final bool isHome;

  const FootballKeyEvent({
    required this.clock,
    required this.type,
    required this.playerName,
    required this.teamName,
    required this.isHome,
  });
}

class FootballPlayerLineup {
  final String jersey;
  final String name;
  final String position;
  final bool isStarter;

  const FootballPlayerLineup({
    required this.jersey,
    required this.name,
    required this.position,
    this.isStarter = true,
  });
}

class FootballMatchModel extends MatchModel {
  final String? homeFormation;
  final String? awayFormation;
  final List<FootballKeyEvent> keyEvents;
  final List<FootballPlayerLineup> homeLineup;
  final List<FootballPlayerLineup> awayLineup;
  final String? attendance;
  final String? homePossession;
  final String? awayPossession;

  FootballMatchModel({
    required super.id,
    required super.leagueName,
    super.leagueId,
    required super.homeTeam,
    required super.awayTeam,
    required super.homeScore,
    required super.awayScore,
    required super.statusDetail,
    required super.state,
    super.homeLogo,
    super.awayLogo,
    super.venue,
    this.homeFormation,
    this.awayFormation,
    this.keyEvents = const [],
    this.homeLineup = const [],
    this.awayLineup = const [],
    this.attendance,
    this.homePossession,
    this.awayPossession,
  }) : super(sportType: SportType.football);

  factory FootballMatchModel.fromEspnJson(
    Map<String, dynamic> json,
    String defaultLeague, {
    String? leagueId,
  }) {
    final base = MatchModel.fromJson(
      json,
      defaultLeague,
      sportType: SportType.football,
      leagueId: leagueId,
    );

    final competitions = json['competitions'] as List<dynamic>?;
    final competition = (competitions != null && competitions.isNotEmpty)
        ? competitions.first as Map<String, dynamic>
        : <String, dynamic>{};

    final details = competition['details'] as List<dynamic>? ?? [];
    final competitors = competition['competitors'] as List<dynamic>? ?? [];

    String? homeId;
    String? homeForm;
    String? awayForm;
    String? homePoss;
    String? awayPoss;

    for (final comp in competitors) {
      if (comp is Map<String, dynamic>) {
        final team = comp['team'] as Map<String, dynamic>? ?? {};
        final stats = comp['statistics'] as List<dynamic>? ?? [];
        String? possession;
        for (final s in stats) {
          if (s is Map<String, dynamic> &&
              (s['name'] == 'possessionPct' || s['abbreviation'] == 'POSS')) {
            possession = s['displayValue']?.toString();
          }
        }
        if (comp['homeAway'] == 'home') {
          homeId = team['id']?.toString();
          homeForm = comp['formation']?.toString();
          homePoss = possession;
        } else if (comp['homeAway'] == 'away') {
          awayForm = comp['formation']?.toString();
          awayPoss = possession;
        }
      }
    }

    final List<FootballKeyEvent> parsedEvents = [];
    for (final item in details) {
      if (item is Map<String, dynamic>) {
        final clockObj = item['clock'] as Map<String, dynamic>? ?? {};
        final typeObj = item['type'] as Map<String, dynamic>? ?? {};
        final teamObj = item['team'] as Map<String, dynamic>? ?? {};
        final athletes = item['athletesInvolved'] as List<dynamic>? ?? [];
        final firstAthlete = athletes.isNotEmpty && athletes.first is Map<String, dynamic>
            ? athletes.first as Map<String, dynamic>
            : <String, dynamic>{};

        final isGoal = item['scoringPlay'] == true;
        final isCard = item['yellowCard'] == true || item['redCard'] == true;
        final String eventType = isGoal
            ? 'Goal'
            : (item['redCard'] == true
                ? 'Red Card'
                : (item['yellowCard'] == true
                    ? 'Yellow Card'
                    : (typeObj['text']?.toString() ?? 'Event')));

        if (isGoal || isCard || parsedEvents.length < 8) {
          final eventTeamId = teamObj['id']?.toString();
          final isHomeTeam = eventTeamId != null && eventTeamId == homeId;
          parsedEvents.add(
            FootballKeyEvent(
              clock: clockObj['displayValue']?.toString() ?? '',
              type: eventType,
              playerName: firstAthlete['displayName']?.toString() ??
                  firstAthlete['shortName']?.toString() ??
                  'Player',
              teamName: isHomeTeam ? base.homeTeam : base.awayTeam,
              isHome: isHomeTeam,
            ),
          );
        }
      }
    }

    return FootballMatchModel(
      id: base.id,
      leagueName: base.leagueName,
      homeTeam: base.homeTeam,
      awayTeam: base.awayTeam,
      homeScore: base.homeScore,
      awayScore: base.awayScore,
      statusDetail: base.statusDetail,
      state: base.state,
      homeLogo: base.homeLogo,
      awayLogo: base.awayLogo,
      venue: base.venue,
      homeFormation: homeForm ?? '4-3-3',
      awayFormation: awayForm ?? '4-2-3-1',
      keyEvents: parsedEvents,
      attendance: competition['attendance']?.toString(),
      homePossession: homePoss,
      awayPossession: awayPoss,
    );
  }

  factory FootballMatchModel.demoLive({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final fakeHomeScore = (currentTime.second % 4 + 1).toString();
    final fakeAwayScore = (currentTime.second % 3).toString();

    return FootballMatchModel(
      id: 'demo_live_999',
      leagueName: 'Demo Evaluation League',
      homeTeam: 'LBRCE Titans',
      awayTeam: 'Rival College',
      homeScore: fakeHomeScore,
      awayScore: fakeAwayScore,
      statusDetail: '75\'',
      state: 'in',
      homeLogo:
          'https://a.espncdn.com/i/teamlogos/soccer/500/default-team-logo-500.png',
      awayLogo:
          'https://a.espncdn.com/i/teamlogos/soccer/500/default-team-logo-500.png',
      venue: 'LBRCE Main Stadium',
      homeFormation: '4-3-3',
      awayFormation: '4-4-2',
      homePossession: '58%',
      awayPossession: '42%',
      keyEvents: const [
        FootballKeyEvent(
          clock: '14\'',
          type: 'Goal',
          playerName: 'K. Arjun',
          teamName: 'LBRCE Titans',
          isHome: true,
        ),
        FootballKeyEvent(
          clock: '39\'',
          type: 'Yellow Card',
          playerName: 'M. Dinesh',
          teamName: 'Rival College',
          isHome: false,
        ),
        FootballKeyEvent(
          clock: '62\'',
          type: 'Goal',
          playerName: 'R. Sai',
          teamName: 'LBRCE Titans',
          isHome: true,
        ),
      ],
      homeLineup: const [
        FootballPlayerLineup(jersey: '1', name: 'V. Prasad (GK)', position: 'GK'),
        FootballPlayerLineup(jersey: '4', name: 'S. Teja', position: 'DF'),
        FootballPlayerLineup(jersey: '8', name: 'R. Sai (C)', position: 'MF'),
        FootballPlayerLineup(jersey: '9', name: 'K. Arjun', position: 'FW'),
        FootballPlayerLineup(jersey: '10', name: 'A.Naveen', position: 'FW'),
      ],
      awayLineup: const [
        FootballPlayerLineup(jersey: '1', name: 'R. Kumar (GK)', position: 'GK'),
        FootballPlayerLineup(jersey: '5', name: 'M. Dinesh', position: 'DF'),
        FootballPlayerLineup(jersey: '6', name: 'P. Vikram', position: 'MF'),
        FootballPlayerLineup(jersey: '11', name: 'T. Rohit', position: 'FW'),
      ],
    );
  }
}
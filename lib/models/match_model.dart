import '../core/models/sport_event.dart';
import '../core/models/sport_type.dart';

class MatchModel implements SportEvent {
  @override
  final String id;
  @override
  final String leagueName;
  final String? leagueId;
  final String homeTeam;
  final String awayTeam;
  final String homeScore;
  final String awayScore;
  @override
  final String statusDetail;
  @override
  final String state; // 'pre' (upcoming), 'in' (live), 'post' (finished)
  final String? homeLogo;
  final String? awayLogo;
  @override
  final SportType sportType;
  final String? venue;

  MatchModel({
    required this.id,
    required this.leagueName,
    this.leagueId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.statusDetail,
    required this.state,
    this.homeLogo,
    this.awayLogo,
    this.sportType = SportType.football,
    this.venue,
  });

  @override
  bool get isLive => state == 'in';

  @override
  bool get isUpcoming => state == 'pre';

  @override
  bool get isFinished => state == 'post';

  @override
  EventLifecycleState get lifecycleState =>
      EventLifecycleState.fromRawState(state);

  factory MatchModel.fromJson(
    Map<String, dynamic> json,
    String defaultLeague, {
    SportType sportType = SportType.football,
    String? leagueId,
  }) {
    final competitions = json['competitions'] as List<dynamic>?;
    final competition = (competitions != null && competitions.isNotEmpty)
        ? competitions.first as Map<String, dynamic>
        : <String, dynamic>{};

    final competitors = competition['competitors'] as List<dynamic>? ?? [];

    Map<String, dynamic> homeComp = {};
    Map<String, dynamic> awayComp = {};

    for (final comp in competitors) {
      if (comp is Map<String, dynamic>) {
        if (comp['homeAway'] == 'home') {
          homeComp = comp;
        } else if (comp['homeAway'] == 'away') {
          awayComp = comp;
        }
      }
    }

    if (homeComp.isEmpty && competitors.isNotEmpty && competitors[0] is Map<String, dynamic>) {
      homeComp = competitors[0] as Map<String, dynamic>;
    }
    if (awayComp.isEmpty && competitors.length > 1 && competitors[1] is Map<String, dynamic>) {
      awayComp = competitors[1] as Map<String, dynamic>;
    }

    final homeTeamObj = homeComp['team'] as Map<String, dynamic>? ?? {};
    final awayTeamObj = awayComp['team'] as Map<String, dynamic>? ?? {};

    final statusObj = json['status'] as Map<String, dynamic>? ?? {};
    final statusType = statusObj['type'] as Map<String, dynamic>? ?? {};
    final venueObj = competition['venue'] as Map<String, dynamic>? ?? {};

    return MatchModel(
      id: json['id']?.toString() ?? '',
      leagueName: defaultLeague,
      leagueId: leagueId,
      homeTeam: homeTeamObj['shortDisplayName']?.toString() ??
          homeTeamObj['displayName']?.toString() ??
          'Home Team',
      awayTeam: awayTeamObj['shortDisplayName']?.toString() ??
          awayTeamObj['displayName']?.toString() ??
          'Away Team',
      homeScore: homeComp['score']?.toString() ?? '0',
      awayScore: awayComp['score']?.toString() ?? '0',
      statusDetail: statusType['shortDetail']?.toString() ?? 'Scheduled',
      state: statusType['state']?.toString() ?? 'pre',
      homeLogo: homeTeamObj['logo']?.toString(),
      awayLogo: awayTeamObj['logo']?.toString(),
      sportType: sportType,
      venue: venueObj['fullName']?.toString(),
    );
  }
}
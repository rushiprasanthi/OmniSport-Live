import '../../../core/models/sport_event.dart';
import '../../../core/models/sport_type.dart';

enum CricketFormat {
  test('TEST'),
  odi('ODI'),
  t20('T20');

  final String label;
  const CricketFormat(this.label);

  static CricketFormat fromString(String raw) {
    final upper = raw.toUpperCase();
    if (upper.contains('TEST')) return CricketFormat.test;
    if (upper.contains('ODI') || upper.contains('ONE DAY')) {
      return CricketFormat.odi;
    }
    return CricketFormat.t20;
  }
}

class CricketInnings {
  final String teamName;
  final String shortTeamName;
  final int inningsNumber;
  final int runs;
  final int wickets;
  final String overs;
  final bool isCurrent;
  final bool isDeclared;

  const CricketInnings({
    required this.teamName,
    required this.shortTeamName,
    required this.inningsNumber,
    required this.runs,
    required this.wickets,
    required this.overs,
    this.isCurrent = false,
    this.isDeclared = false,
  });

  String get formattedScore {
    final wktPart = wickets >= 10 ? '' : '/$wickets';
    final decPart = isDeclared ? 'd' : '';
    return '$runs$wktPart$decPart ($overs ov)';
  }
}

class CricketMatchModel implements SportEvent {
  @override
  final String id;
  @override
  final String leagueName;
  final CricketFormat format;
  final String teamA;
  final String teamB;
  final String teamAShort;
  final String teamBShort;
  final List<CricketInnings> innings;
  final double? currentRunRate;
  final double? requiredRunRate;
  final String tossSummary;
  final String matchNote;
  @override
  final String statusDetail;
  @override
  final String state;
  final String venue;
  final List<String> activeBatters;
  final List<String> activeBowlers;

  const CricketMatchModel({
    required this.id,
    required this.leagueName,
    required this.format,
    required this.teamA,
    required this.teamB,
    required this.teamAShort,
    required this.teamBShort,
    required this.innings,
    this.currentRunRate,
    this.requiredRunRate,
    required this.tossSummary,
    required this.matchNote,
    required this.statusDetail,
    required this.state,
    required this.venue,
    this.activeBatters = const [],
    this.activeBowlers = const [],
  });

  @override
  SportType get sportType => SportType.cricket;

  @override
  bool get isLive => state == 'in';

  @override
  bool get isUpcoming => state == 'pre';

  @override
  bool get isFinished => state == 'post';

  @override
  EventLifecycleState get lifecycleState =>
      EventLifecycleState.fromRawState(state);

  String scoreForTeam(String teamShort, String fullName) {
    final teamInnings = innings
        .where((i) => i.shortTeamName == teamShort || i.teamName == fullName)
        .toList();
    if (teamInnings.isEmpty) {
      return state == 'pre' ? 'Yet to bat' : '0/0 (0.0 ov)';
    }
    return teamInnings.map((i) => i.formattedScore).join(' & ');
  }

  factory CricketMatchModel.fromEspnJson(
    Map<String, dynamic> json,
    String defaultSeries,
    CricketFormat defaultFormat,
  ) {
    String safeShortCode(String? abbr, String fullName, String fallback) {
      if (abbr != null && abbr.trim().isNotEmpty) return abbr.trim().toUpperCase();
      final clean = fullName.trim();
      if (clean.isEmpty) return fallback;
      return (clean.length >= 3 ? clean.substring(0, 3) : clean).toUpperCase();
    }

    final competitions = json['competitions'] as List<dynamic>?;
    final competition = (competitions != null && competitions.isNotEmpty)
        ? competitions.first as Map<String, dynamic>
        : <String, dynamic>{};

    final competitors = competition['competitors'] as List<dynamic>? ?? [];
    final compA = competitors.isNotEmpty && competitors[0] is Map<String, dynamic>
        ? competitors[0] as Map<String, dynamic>
        : <String, dynamic>{};
    final compB = competitors.length > 1 && competitors[1] is Map<String, dynamic>
        ? competitors[1] as Map<String, dynamic>
        : <String, dynamic>{};

    final teamAObj = compA['team'] as Map<String, dynamic>? ?? {};
    final teamBObj = compB['team'] as Map<String, dynamic>? ?? {};

    final teamAName = teamAObj['displayName']?.toString() ?? 'Team A';
    final teamBName = teamBObj['displayName']?.toString() ?? 'Team B';
    final teamAShort = safeShortCode(
      teamAObj['abbreviation']?.toString(),
      teamAName,
      'TEAM',
    );
    final teamBShort = safeShortCode(
      teamBObj['abbreviation']?.toString(),
      teamBName,
      'TEAM',
    );

    final List<CricketInnings> parsedInnings = <CricketInnings>[];

    void extractLinescores(
      Map<String, dynamic> comp,
      String tName,
      String tShort,
    ) {
      final linescores = comp['linescores'] as List<dynamic>? ?? [];
      if (linescores.isNotEmpty) {
        for (int i = 0; i < linescores.length; i++) {
          final ls = linescores[i];
          if (ls is Map<String, dynamic>) {
            parsedInnings.add(
              CricketInnings(
                teamName: tName,
                shortTeamName: tShort,
                inningsNumber: i + 1,
                runs: int.tryParse(ls['runs']?.toString() ?? '') ??
                    int.tryParse(comp['score']?.toString() ?? '0') ??
                    0,
                wickets: int.tryParse(ls['wickets']?.toString() ?? '0') ?? 0,
                overs: ls['overs']?.toString() ?? '0.0',
                isCurrent: ls['isBatting'] == true,
              ),
            );
          }
        }
      } else if (comp['score'] != null && comp['score'].toString().isNotEmpty) {
        final rawScore = comp['score'].toString();
        final parts = rawScore.split('/');
        final runs = int.tryParse(parts.first.trim()) ?? 0;
        final wkts = parts.length > 1
            ? (int.tryParse(parts[1].split(' ').first.trim()) ?? 0)
            : 0;
        parsedInnings.add(
          CricketInnings(
            teamName: tName,
            shortTeamName: tShort,
            inningsNumber: 1,
            runs: runs,
            wickets: wkts,
            overs: '20.0',
          ),
        );
      }
    }

    extractLinescores(compA, teamAName, teamAShort);
    extractLinescores(compB, teamBName, teamBShort);

    final statusObj = json['status'] as Map<String, dynamic>? ?? {};
    final statusType = statusObj['type'] as Map<String, dynamic>? ?? {};
    final venueObj = competition['venue'] as Map<String, dynamic>? ?? {};
    final classObj = competition['class'] as Map<String, dynamic>? ?? {};

    final formatStr = classObj['generalClassCard']?.toString() ??
        json['name']?.toString() ??
        defaultFormat.label;

    return CricketMatchModel(
      id: json['id']?.toString() ?? '',
      leagueName: defaultSeries,
      format: CricketFormat.fromString(formatStr),
      teamA: teamAName,
      teamB: teamBName,
      teamAShort: teamAShort,
      teamBShort: teamBShort,
      innings: parsedInnings,
      tossSummary: competition['note']?.toString() ??
          'Toss details recorded at match start',
      matchNote: statusType['detail']?.toString() ??
          statusType['description']?.toString() ??
          'Scheduled Fixture',
      statusDetail: statusType['shortDetail']?.toString() ?? 'Live',
      state: statusType['state']?.toString() ?? 'pre',
      venue: venueObj['fullName']?.toString() ??
          'International Cricket Stadium',
    );
  }
}
import '../../../core/models/sport_event.dart';
import '../../../core/models/sport_type.dart';

typedef F1DriverResult = F1DriverClassification;

class F1SessionSchedule {
  final String name;
  final String status;
  final String dateTimeLabel;

  const F1SessionSchedule({
    required this.name,
    required this.status,
    required this.dateTimeLabel,
  });

  String get dateString => dateTimeLabel;
  String get timeString => status;
  bool get isCompleted => status.toLowerCase() == 'completed';
}

class F1DriverClassification {
  final int position;
  final String driverName;
  final String driverCode;
  final String constructorName;
  final int startingGrid;
  final String timeOrGap;
  final String fastestLap;
  final int points;

  const F1DriverClassification({
    required this.position,
    required this.driverName,
    required this.driverCode,
    required this.constructorName,
    required this.startingGrid,
    required this.timeOrGap,
    required this.fastestLap,
    required this.points,
  });

  String get timeOrStatus => timeOrGap;
  int get gridPosition => startingGrid;
}

class F1RaceModel implements SportEvent {
  @override
  final String id;
  final int round;
  final String grandPrixName;
  final String circuitName;
  final String locality;
  final String season;
  final String country;
  final String dateFormatted;
  final int totalLaps;
  final String? fastestLapDriver;
  @override
  final String statusDetail;
  @override
  final String state;
  final String currentLapSummary;
  final List<F1SessionSchedule> sessions;
  final List<F1DriverClassification> classification;

  const F1RaceModel({
    required this.id,
    required this.round,
    required this.grandPrixName,
    required this.circuitName,
    required this.locality,
    this.season = '2025',
    this.country = '',
    this.dateFormatted = '',
    this.totalLaps = 58,
    this.fastestLapDriver,
    required this.statusDetail,
    required this.state,
    required this.currentLapSummary,
    required this.sessions,
    required this.classification,
  });

  @override
  SportType get sportType => SportType.motorsport;

  @override
  String get leagueName => 'FIA Formula 1 World Championship';

  String get raceName => grandPrixName;
  List<F1DriverClassification> get results => classification;

  @override
  bool get isLive => state == 'in';

  @override
  bool get isUpcoming => state == 'pre';

  @override
  bool get isFinished => state == 'post';

  @override
  EventLifecycleState get lifecycleState =>
      EventLifecycleState.fromRawState(state);

  factory F1RaceModel.fromJolpicaJson(Map<String, dynamic> json) {
    final circuit = json['Circuit'] as Map<String, dynamic>? ?? {};
    final location = circuit['Location'] as Map<String, dynamic>? ?? {};
    final results = json['Results'] as List<dynamic>? ?? [];
    final seasonValue = json['season']?.toString() ?? '2025';
    final raceDate = json['date']?.toString() ?? '';
    final circuitName = circuit['circuitName']?.toString() ?? 'International Circuit';
    final localityText = location['locality']?.toString() ?? '';
    final countryText = location['country']?.toString() ?? '';

    final List<F1DriverClassification> parsedGrid = <F1DriverClassification>[];
    String? fastestLapDriver;

    for (final r in results) {
      if (r is Map<String, dynamic>) {
        final driver = r['Driver'] as Map<String, dynamic>? ?? {};
        final constructor = r['Constructor'] as Map<String, dynamic>? ?? {};
        final timeObj = r['Time'] as Map<String, dynamic>? ?? {};
        final fastestLapObj = r['FastestLap'] as Map<String, dynamic>? ?? {};
        final flTime = fastestLapObj['Time'] as Map<String, dynamic>? ?? {};
        final driverName =
            '${driver['givenName'] ?? ''} ${driver['familyName'] ?? ''}'.trim();
        final driverCode = driver['code']?.toString() ?? 'DRV';

        if (fastestLapDriver == null && flTime['time'] != null) {
          fastestLapDriver = driverCode;
        }

        parsedGrid.add(
          F1DriverClassification(
            position: int.tryParse(r['position']?.toString() ?? '0') ?? 0,
            driverName: driverName,
            driverCode: driverCode,
            constructorName: constructor['name']?.toString() ?? 'F1 Team',
            startingGrid: int.tryParse(r['grid']?.toString() ?? '1') ?? 1,
            timeOrGap:
                timeObj['time']?.toString() ?? r['status']?.toString() ?? '-',
            fastestLap: flTime['time']?.toString() ?? '-',
            points: double.tryParse(r['points']?.toString() ?? '0')?.round() ?? 0,
          ),
        );
      }
    }

    final bool isCompleted = parsedGrid.isNotEmpty && (json['status']?['state'] ?? 'post') != 'pre';
    final raceName = json['raceName']?.toString() ?? 'Grand Prix';
    final totalLaps = int.tryParse(json['Laps']?['total']?.toString() ?? '58') ?? 58;

    return F1RaceModel(
      id: 'f1_${json['season']}_${json['round']}',
      round: int.tryParse(json['round']?.toString() ?? '1') ?? 1,
      grandPrixName: raceName,
      circuitName: circuitName,
      locality: [localityText, countryText].where((v) => v.isNotEmpty).join(', '),
      season: seasonValue,
      country: countryText,
      dateFormatted: raceDate.isNotEmpty ? raceDate : 'Weekend Schedule',
      totalLaps: totalLaps,
      fastestLapDriver: fastestLapDriver,
      statusDetail: isCompleted ? 'Race Finished' : 'Scheduled ($raceDate)',
      state: isCompleted ? 'post' : 'pre',
      currentLapSummary: isCompleted ? 'Classified Finish' : 'Weekend Schedule',
      sessions: const [
        F1SessionSchedule(
          name: 'Practice 1 (FP1)',
          status: 'Completed',
          dateTimeLabel: 'Fri • 60 Mins',
        ),
        F1SessionSchedule(
          name: 'Qualifying (Q1/Q2/Q3)',
          status: 'Completed',
          dateTimeLabel: 'Sat • Starting Grid Set',
        ),
        F1SessionSchedule(
          name: 'Grand Prix Race',
          status: 'Completed',
          dateTimeLabel: 'Sun • Weekend Schedule',
        ),
      ],
      classification: parsedGrid,
    );
  }
}
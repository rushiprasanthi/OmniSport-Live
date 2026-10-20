import 'sport_type.dart';

class SportLeague {
  final String id;
  final String path;
  final String title;
  final SportType sportType;
  final String? shortCode;

  const SportLeague({
    required this.id,
    required this.path,
    required this.title,
    required this.sportType,
    this.shortCode,
  });
}

class SportLeagueCatalog {
  static const List<SportLeague> allLeagues = [
    // FOOTBALL (SOCCER) - Preserved from original HomeScreen
    SportLeague(
      id: 'eng.1',
      path: 'soccer/eng.1',
      title: 'Premier League (ENG)',
      sportType: SportType.football,
      shortCode: 'EPL',
    ),
    SportLeague(
      id: 'esp.1',
      path: 'soccer/esp.1',
      title: 'La Liga (ESP)',
      sportType: SportType.football,
      shortCode: 'LAL',
    ),
    SportLeague(
      id: 'uefa.champions',
      path: 'soccer/uefa.champions',
      title: 'Champions League',
      sportType: SportType.football,
      shortCode: 'UCL',
    ),
    SportLeague(
      id: 'uefa.europa',
      path: 'soccer/uefa.europa',
      title: 'Europa League',
      sportType: SportType.football,
      shortCode: 'UEL',
    ),
    SportLeague(
      id: 'ita.1',
      path: 'soccer/ita.1',
      title: 'Serie A (ITA)',
      sportType: SportType.football,
      shortCode: 'SER',
    ),
    SportLeague(
      id: 'ger.1',
      path: 'soccer/ger.1',
      title: 'Bundesliga (GER)',
      sportType: SportType.football,
      shortCode: 'BUN',
    ),
    SportLeague(
      id: 'fra.1',
      path: 'soccer/fra.1',
      title: 'Ligue 1 (FRA)',
      sportType: SportType.football,
      shortCode: 'L1',
    ),
    SportLeague(
      id: 'usa.1',
      path: 'soccer/usa.1',
      title: 'MLS (USA)',
      sportType: SportType.football,
      shortCode: 'MLS',
    ),
    SportLeague(
      id: 'mex.1',
      path: 'soccer/mex.1',
      title: 'Liga MX (MEX)',
      sportType: SportType.football,
      shortCode: 'LMX',
    ),

    // CRICKET - International & T20 Franchises
    SportLeague(
      id: 'icc.t20',
      path: 'cricket/8676',
      title: 'International T20I',
      sportType: SportType.cricket,
      shortCode: 'T20I',
    ),
    SportLeague(
      id: 'icc.odi',
      path: 'cricket/8678',
      title: 'ODI Internationals',
      sportType: SportType.cricket,
      shortCode: 'ODI',
    ),
    SportLeague(
      id: 'icc.test',
      path: 'cricket/8674',
      title: 'ICC World Test Championship',
      sportType: SportType.cricket,
      shortCode: 'TEST',
    ),
    SportLeague(
      id: 'ipl',
      path: 'cricket/8048',
      title: 'Indian Premier League (IPL)',
      sportType: SportType.cricket,
      shortCode: 'IPL',
    ),

    // MOTORSPORT (FORMULA 1)
    SportLeague(
      id: 'f1.world',
      path: 'racing/f1',
      title: 'FIA Formula 1 World Championship',
      sportType: SportType.motorsport,
      shortCode: 'F1',
    ),
    SportLeague(
      id: 'f1.constructors',
      path: 'racing/f1/constructors',
      title: 'F1 Constructors Championship',
      sportType: SportType.motorsport,
      shortCode: 'WCC',
    ),

    // BASKETBALL - Preserved from original HomeScreen
    SportLeague(
      id: 'nba',
      path: 'basketball/nba',
      title: 'NBA',
      sportType: SportType.basketball,
      shortCode: 'NBA',
    ),
    SportLeague(
      id: 'wnba',
      path: 'basketball/wnba',
      title: 'WNBA',
      sportType: SportType.basketball,
      shortCode: 'WNBA',
    ),
    SportLeague(
      id: 'ncaa.mbb',
      path: 'basketball/mens-college-basketball',
      title: 'NCAA Men\'s Basketball',
      sportType: SportType.basketball,
      shortCode: 'NCAAB',
    ),

    // AMERICAN FOOTBALL - Preserved from original HomeScreen
    SportLeague(
      id: 'nfl',
      path: 'football/nfl',
      title: 'NFL',
      sportType: SportType.americanFootball,
      shortCode: 'NFL',
    ),
    SportLeague(
      id: 'ncaa.fb',
      path: 'football/college-football',
      title: 'NCAA Football',
      sportType: SportType.americanFootball,
      shortCode: 'NCAAF',
    ),

    // BASEBALL - Preserved from original HomeScreen
    SportLeague(
      id: 'mlb',
      path: 'baseball/mlb',
      title: 'MLB Baseball',
      sportType: SportType.baseball,
      shortCode: 'MLB',
    ),
    SportLeague(
      id: 'ncaa.bb',
      path: 'baseball/college-baseball',
      title: 'NCAA Baseball',
      sportType: SportType.baseball,
      shortCode: 'NCAABB',
    ),

    // HOCKEY - Preserved from original HomeScreen
    SportLeague(
      id: 'nhl',
      path: 'hockey/nhl',
      title: 'NHL Hockey',
      sportType: SportType.hockey,
      shortCode: 'NHL',
    ),
  ];

  static List<SportLeague> forSport(SportType sportType) {
    return allLeagues.where((l) => l.sportType == sportType).toList();
  }
}
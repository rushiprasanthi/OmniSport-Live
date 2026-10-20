class StandingsTable {
  final String title;
  final String subtitle;
  final List<String> columns;
  final List<StandingsRow> rows;

  const StandingsTable({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.rows,
  });
}

class StandingsRow {
  final int rank;
  final String entityName;
  final String? entitySubtitle;
  final String? logoUrl;
  final List<String> cells;
  final String highlightPoints;

  const StandingsRow({
    required this.rank,
    required this.entityName,
    this.entitySubtitle,
    this.logoUrl,
    required this.cells,
    required this.highlightPoints,
  });
}
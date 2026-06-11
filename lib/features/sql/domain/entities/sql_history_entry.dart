class SqlHistoryEntry {
  SqlHistoryEntry({
    required this.id,
    required this.query,
    required this.executedAt,
    this.isFavorite = false,
  });

  final String id;
  final String query;
  final DateTime executedAt;
  bool isFavorite;
}

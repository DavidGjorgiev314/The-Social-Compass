class HistoryEntry {
  const HistoryEntry({
    required this.nodeId,
    required this.choiceId,
    required this.statsAfter,
    required this.at,
  });

  final String nodeId;
  final String choiceId;
  final Map<String, int> statsAfter;
  final DateTime at;

  Map<String, dynamic> toMap() => {
        'nodeId': nodeId,
        'choiceId': choiceId,
        'statsAfter': statsAfter,
        'at': at.toIso8601String(),
      };

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    final rawStats = (map['statsAfter'] as Map?) ?? const {};
    return HistoryEntry(
      nodeId: map['nodeId'] as String? ?? '',
      choiceId: map['choiceId'] as String? ?? '',
      statsAfter: rawStats.map(
        (key, value) => MapEntry(key as String, (value as num).toInt()),
      ),
      at: DateTime.tryParse(map['at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

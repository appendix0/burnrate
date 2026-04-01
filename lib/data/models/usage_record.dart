class UsageRecord {
  const UsageRecord({
    required this.date,
    required this.costUsd,
    this.tokens,
  });

  final DateTime date;
  final double costUsd;
  final int? tokens;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'costUsd': costUsd,
        if (tokens != null) 'tokens': tokens,
      };

  factory UsageRecord.fromJson(Map<String, dynamic> json) => UsageRecord(
        date: DateTime.parse(json['date'] as String),
        costUsd: (json['costUsd'] as num).toDouble(),
        tokens: json['tokens'] as int?,
      );
}

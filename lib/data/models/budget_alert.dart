import 'dart:convert';

import 'package:burnrate/data/models/service_type.dart';

class BudgetAlert {
  const BudgetAlert({
    required this.serviceType,
    required this.thresholdUsd,
    required this.isEnabled,
    this.lastTriggeredAt,
  });

  final ServiceType serviceType;
  final double thresholdUsd;
  final bool isEnabled;
  final DateTime? lastTriggeredAt;

  BudgetAlert copyWith({
    double? thresholdUsd,
    bool? isEnabled,
    DateTime? lastTriggeredAt,
  }) =>
      BudgetAlert(
        serviceType: serviceType,
        thresholdUsd: thresholdUsd ?? this.thresholdUsd,
        isEnabled: isEnabled ?? this.isEnabled,
        lastTriggeredAt: lastTriggeredAt ?? this.lastTriggeredAt,
      );

  Map<String, dynamic> toJson() => {
        'serviceType': serviceType.name,
        'thresholdUsd': thresholdUsd,
        'isEnabled': isEnabled,
        if (lastTriggeredAt != null)
          'lastTriggeredAt': lastTriggeredAt!.toIso8601String(),
      };

  factory BudgetAlert.fromJson(Map<String, dynamic> json) => BudgetAlert(
        serviceType:
            ServiceType.values.byName(json['serviceType'] as String),
        thresholdUsd: (json['thresholdUsd'] as num).toDouble(),
        isEnabled: json['isEnabled'] as bool,
        lastTriggeredAt: json['lastTriggeredAt'] != null
            ? DateTime.parse(json['lastTriggeredAt'] as String)
            : null,
      );

  String toJsonString() => jsonEncode(toJson());

  static BudgetAlert fromJsonString(String raw) =>
      BudgetAlert.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

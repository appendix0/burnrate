import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_record.dart';

class UsageSummary {
  const UsageSummary({
    required this.serviceType,
    required this.currentPeriodCostUsd,
    required this.previousPeriodCostUsd,
    required this.dailyRecords,
    required this.fetchedAt,
  });

  final ServiceType serviceType;
  final double currentPeriodCostUsd;
  final double previousPeriodCostUsd;
  final List<UsageRecord> dailyRecords;
  final DateTime fetchedAt;

  double get periodDelta => currentPeriodCostUsd - previousPeriodCostUsd;

  bool get isUp => periodDelta > 0;
}

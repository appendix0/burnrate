import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_record.dart';
import 'package:burnrate/data/models/usage_summary.dart';
import 'package:burnrate/domain/interfaces/billing_provider.dart';
import 'package:dio/dio.dart';

class OpenAISource implements BillingProvider {
  OpenAISource(this._dio);

  final Dio _dio;

  @override
  ServiceType get serviceType => ServiceType.openai;

  @override
  Future<UsageSummary> fetchUsage(Credential credential) async {
    final cred = credential as OpenAICredential;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPrevMonth = startOfMonth.subtract(const Duration(days: 1));

    final current = await _fetchPeriod(cred.apiKey, startOfMonth, now);
    final previous =
        await _fetchPeriod(cred.apiKey, startOfPrevMonth, endOfPrevMonth);

    return UsageSummary(
      serviceType: ServiceType.openai,
      currentPeriodCostUsd: current.total,
      previousPeriodCostUsd: previous.total,
      dailyRecords: current.records,
      fetchedAt: now,
    );
  }

  Future<({double total, List<UsageRecord> records})> _fetchPeriod(
    String apiKey,
    DateTime start,
    DateTime end,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://api.openai.com/v1/dashboard/billing/usage',
      queryParameters: {
        'start_date': _fmt(start),
        'end_date': _fmt(end),
      },
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
      }),
    );

    final data = response.data!;
    // total_usage is returned in cents
    final totalCents = (data['total_usage'] as num?)?.toDouble() ?? 0.0;
    final totalUsd = totalCents / 100.0;

    final dailyCosts = data['daily_costs'] as List<dynamic>? ?? [];
    final records = <UsageRecord>[];

    for (final day in dailyCosts) {
      final map = day as Map<String, dynamic>;
      final ts = (map['timestamp'] as num).toInt();
      final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      final lineItems = map['line_items'] as List<dynamic>? ?? [];
      final dayCostCents = lineItems.fold<double>(
        0,
        (sum, item) =>
            sum + ((item as Map)['cost'] as num? ?? 0).toDouble(),
      );
      records.add(UsageRecord(date: date, costUsd: dayCostCents / 100.0));
    }

    return (total: totalUsd, records: records);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

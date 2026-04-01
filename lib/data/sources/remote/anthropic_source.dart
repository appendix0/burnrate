import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_record.dart';
import 'package:burnrate/data/models/usage_summary.dart';
import 'package:burnrate/domain/interfaces/billing_provider.dart';
import 'package:dio/dio.dart';

class AnthropicSource implements BillingProvider {
  AnthropicSource(this._dio);

  final Dio _dio;

  @override
  ServiceType get serviceType => ServiceType.anthropic;

  @override
  Future<UsageSummary> fetchUsage(Credential credential) async {
    final cred = credential as AnthropicCredential;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPrevMonth = startOfMonth.subtract(const Duration(days: 1));

    final current = await _fetchPeriod(
      cred.apiKey,
      startOfMonth,
      now,
    );
    final previous = await _fetchPeriod(
      cred.apiKey,
      startOfPrevMonth,
      endOfPrevMonth,
    );

    return UsageSummary(
      serviceType: ServiceType.anthropic,
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
      'https://api.anthropic.com/v1/usage',
      queryParameters: {
        'start_date': _fmt(start),
        'end_date': _fmt(end),
        'granularity': 'day',
      },
      options: Options(headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      }),
    );

    final data = response.data!;
    final items = data['data'] as List<dynamic>? ?? [];

    double total = 0;
    final records = <UsageRecord>[];

    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final costUsd = (map['cost_usd'] as num?)?.toDouble() ?? 0.0;
      final inputTokens = (map['input_tokens'] as num?)?.toInt() ?? 0;
      final outputTokens = (map['output_tokens'] as num?)?.toInt() ?? 0;
      final date = DateTime.tryParse(map['date'] as String? ?? '') ?? start;

      total += costUsd;
      records.add(UsageRecord(
        date: date,
        costUsd: costUsd,
        tokens: inputTokens + outputTokens,
      ));
    }

    return (total: total, records: records);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

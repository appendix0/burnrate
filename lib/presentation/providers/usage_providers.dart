import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_summary.dart';
import 'package:burnrate/data/sources/remote/anthropic_source.dart';
import 'package:burnrate/data/sources/remote/openai_source.dart';
import 'package:burnrate/domain/interfaces/billing_provider.dart';
import 'package:burnrate/presentation/providers/credential_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── HTTP client ───────────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

// ── Billing sources ───────────────────────────────────────────────────────────

final billingSourcesProvider = Provider<Map<ServiceType, BillingProvider>>((ref) {
  final dio = ref.watch(dioProvider);
  return {
    ServiceType.anthropic: AnthropicSource(dio),
    ServiceType.openai: OpenAISource(dio),
    // ServiceType.aws: AwsSource(dio),       — Phase 4
    // ServiceType.oracle: OracleSource(dio),  — Phase 6
    // ServiceType.gemini: GeminiSource(dio),  — Phase 8
  };
});

// ── Usage fetching ────────────────────────────────────────────────────────────

final usageSummaryProvider =
    FutureProvider.family<UsageSummary, ServiceType>((ref, type) async {
  final credential = await ref.watch(credentialProvider(type).future);
  if (credential == null) {
    throw StateError('No credential configured for ${type.name}');
  }
  final sources = ref.watch(billingSourcesProvider);
  final source = sources[type];
  if (source == null) {
    throw UnimplementedError('${type.name} billing not implemented yet');
  }
  return source.fetchUsage(credential);
});

final totalSpendProvider = FutureProvider<double>((ref) async {
  final configured = await ref.watch(configuredServicesProvider.future);
  double total = 0;
  for (final type in configured) {
    final summary = await ref.watch(usageSummaryProvider(type).future);
    total += summary.currentPeriodCostUsd;
  }
  return total;
});

final totalCapacityProvider = Provider<double?>((ref) {
  final capacities = ref.watch(allCapacitiesProvider);
  if (capacities.isEmpty) return null;
  return capacities.values.fold(0.0, (sum, c) => sum + c);
});

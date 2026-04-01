import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_summary.dart';

/// In-memory cache for usage summaries fetched during the current session.
/// Data is not persisted to disk — each app launch fetches fresh from APIs.
class UsageRepository {
  final Map<ServiceType, UsageSummary> _cache = {};

  UsageSummary? get(ServiceType type) => _cache[type];

  void put(ServiceType type, UsageSummary summary) {
    _cache[type] = summary;
  }

  void invalidate(ServiceType type) {
    _cache.remove(type);
  }

  void invalidateAll() {
    _cache.clear();
  }

  bool isCached(ServiceType type) => _cache.containsKey(type);
}

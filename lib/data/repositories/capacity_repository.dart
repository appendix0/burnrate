import 'dart:convert';

import 'package:burnrate/core/constants/storage_keys.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CapacityRepository {
  CapacityRepository(this._prefs);

  final SharedPreferences _prefs;

  Map<ServiceType, double> loadAll() {
    final raw = _prefs.getString(StorageKeys.serviceCapacities);
    if (raw == null) return {};
    final list = jsonDecode(raw) as List<dynamic>;
    return {
      for (final e in list)
        ServiceType.values.byName(e['serviceType'] as String):
            (e['capacityUsd'] as num).toDouble(),
    };
  }

  Future<void> set(ServiceType type, double capacityUsd) async {
    final all = loadAll();
    all[type] = capacityUsd;
    final encoded = jsonEncode(
      all.entries
          .map((e) => {'serviceType': e.key.name, 'capacityUsd': e.value})
          .toList(),
    );
    await _prefs.setString(StorageKeys.serviceCapacities, encoded);
  }

  Future<void> remove(ServiceType type) async {
    final all = loadAll()..remove(type);
    final encoded = jsonEncode(
      all.entries
          .map((e) => {'serviceType': e.key.name, 'capacityUsd': e.value})
          .toList(),
    );
    await _prefs.setString(StorageKeys.serviceCapacities, encoded);
  }

  double? get(ServiceType type) => loadAll()[type];
}

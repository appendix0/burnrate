import 'dart:convert';

import 'package:burnrate/core/constants/storage_keys.dart';
import 'package:burnrate/data/models/budget_alert.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlertRepository {
  AlertRepository(this._prefs);

  final SharedPreferences _prefs;

  List<BudgetAlert> loadAll() {
    final raw = _prefs.getString(StorageKeys.budgetAlerts);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => BudgetAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<BudgetAlert> alerts) async {
    final encoded = jsonEncode(alerts.map((a) => a.toJson()).toList());
    await _prefs.setString(StorageKeys.budgetAlerts, encoded);
  }

  Future<void> upsert(BudgetAlert alert) async {
    final all = loadAll();
    final idx = all.indexWhere((a) => a.serviceType == alert.serviceType);
    if (idx >= 0) {
      all[idx] = alert;
    } else {
      all.add(alert);
    }
    await saveAll(all);
  }

  BudgetAlert? get(ServiceType type) {
    return loadAll().where((a) => a.serviceType == type).firstOrNull;
  }
}

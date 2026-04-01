import 'package:burnrate/core/constants/storage_keys.dart';
import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/repositories/alert_repository.dart';
import 'package:burnrate/data/repositories/credential_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

/// Overridden in main() after SharedPreferences.getInstance()
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

// ── Repositories ──────────────────────────────────────────────────────────────

final credentialRepositoryProvider = Provider<CredentialRepository>((ref) {
  return CredentialRepository(ref.watch(secureStorageProvider));
});

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository(ref.watch(sharedPreferencesProvider));
});

// ── Credentials ───────────────────────────────────────────────────────────────

final configuredServicesProvider = FutureProvider<List<ServiceType>>((ref) {
  return ref.watch(credentialRepositoryProvider).configuredServices();
});

final credentialProvider =
    FutureProvider.family<Credential?, ServiceType>((ref, type) {
  return ref.watch(credentialRepositoryProvider).load(type);
});

// ── Onboarding state ──────────────────────────────────────────────────────────

final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
});

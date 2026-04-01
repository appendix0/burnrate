import 'package:burnrate/core/constants/storage_keys.dart';
import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialRepository {
  CredentialRepository(this._storage);

  final FlutterSecureStorage _storage;

  static String _key(ServiceType type) {
    return switch (type) {
      ServiceType.anthropic => StorageKeys.credentialAnthropic,
      ServiceType.openai => StorageKeys.credentialOpenai,
      ServiceType.gemini => StorageKeys.credentialGemini,
      ServiceType.aws => StorageKeys.credentialAws,
      ServiceType.oracle => StorageKeys.credentialOracle,
    };
  }

  Future<Credential?> load(ServiceType type) async {
    final raw = await _storage.read(key: _key(type));
    if (raw == null) return null;
    return Credential.fromJsonString(type, raw);
  }

  Future<void> save(Credential credential) async {
    await _storage.write(
      key: _key(credential.serviceType),
      value: credential.toJsonString(),
    );
  }

  Future<void> delete(ServiceType type) async {
    await _storage.delete(key: _key(type));
  }

  Future<bool> exists(ServiceType type) async {
    final raw = await _storage.read(key: _key(type));
    return raw != null;
  }

  Future<List<ServiceType>> configuredServices() async {
    final results = <ServiceType>[];
    for (final type in ServiceType.values) {
      if (await exists(type)) results.add(type);
    }
    return results;
  }
}

import 'dart:convert';

import 'package:burnrate/data/models/service_type.dart';

sealed class Credential {
  const Credential();

  ServiceType get serviceType;

  Map<String, dynamic> toJson();

  @override
  String toString() => 'Credential(serviceType: $serviceType, data: [redacted])';

  static Credential fromJson(ServiceType type, Map<String, dynamic> json) {
    return switch (type) {
      ServiceType.anthropic => AnthropicCredential.fromJson(json),
      ServiceType.openai => OpenAICredential.fromJson(json),
      ServiceType.gemini => GeminiCredential.fromJson(json),
      ServiceType.aws => AWSCredential.fromJson(json),
      ServiceType.oracle => OCICredential.fromJson(json),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static Credential fromJsonString(ServiceType type, String raw) =>
      fromJson(type, jsonDecode(raw) as Map<String, dynamic>);
}

class AnthropicCredential extends Credential {
  const AnthropicCredential({required this.apiKey});

  final String apiKey;

  @override
  ServiceType get serviceType => ServiceType.anthropic;

  @override
  Map<String, dynamic> toJson() => {'apiKey': apiKey};

  factory AnthropicCredential.fromJson(Map<String, dynamic> json) =>
      AnthropicCredential(apiKey: json['apiKey'] as String);
}

class OpenAICredential extends Credential {
  const OpenAICredential({required this.apiKey});

  final String apiKey;

  @override
  ServiceType get serviceType => ServiceType.openai;

  @override
  Map<String, dynamic> toJson() => {'apiKey': apiKey};

  factory OpenAICredential.fromJson(Map<String, dynamic> json) =>
      OpenAICredential(apiKey: json['apiKey'] as String);
}

class GeminiCredential extends Credential {
  const GeminiCredential({required this.apiKey, this.projectId});

  final String apiKey;
  final String? projectId;

  @override
  ServiceType get serviceType => ServiceType.gemini;

  @override
  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        if (projectId != null) 'projectId': projectId,
      };

  factory GeminiCredential.fromJson(Map<String, dynamic> json) =>
      GeminiCredential(
        apiKey: json['apiKey'] as String,
        projectId: json['projectId'] as String?,
      );
}

class AWSCredential extends Credential {
  const AWSCredential({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.region,
  });

  final String accessKeyId;
  final String secretAccessKey;
  final String region;

  @override
  ServiceType get serviceType => ServiceType.aws;

  @override
  Map<String, dynamic> toJson() => {
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'region': region,
      };

  factory AWSCredential.fromJson(Map<String, dynamic> json) => AWSCredential(
        accessKeyId: json['accessKeyId'] as String,
        secretAccessKey: json['secretAccessKey'] as String,
        region: json['region'] as String,
      );
}

class OCICredential extends Credential {
  const OCICredential({
    required this.tenancyOcid,
    required this.userOcid,
    required this.fingerprint,
    required this.privateKeyPem,
    required this.region,
  });

  final String tenancyOcid;
  final String userOcid;
  final String fingerprint;
  final String privateKeyPem;
  final String region;

  @override
  ServiceType get serviceType => ServiceType.oracle;

  @override
  Map<String, dynamic> toJson() => {
        'tenancyOcid': tenancyOcid,
        'userOcid': userOcid,
        'fingerprint': fingerprint,
        'privateKeyPem': privateKeyPem,
        'region': region,
      };

  factory OCICredential.fromJson(Map<String, dynamic> json) => OCICredential(
        tenancyOcid: json['tenancyOcid'] as String,
        userOcid: json['userOcid'] as String,
        fingerprint: json['fingerprint'] as String,
        privateKeyPem: json['privateKeyPem'] as String,
        region: json['region'] as String,
      );
}

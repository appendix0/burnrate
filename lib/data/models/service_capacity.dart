import 'package:burnrate/data/models/service_type.dart';

class ServiceCapacity {
  const ServiceCapacity({
    required this.serviceType,
    required this.capacityUsd,
  });

  final ServiceType serviceType;
  final double capacityUsd;

  Map<String, dynamic> toJson() => {
        'serviceType': serviceType.name,
        'capacityUsd': capacityUsd,
      };

  factory ServiceCapacity.fromJson(Map<String, dynamic> json) => ServiceCapacity(
        serviceType: ServiceType.values.byName(json['serviceType'] as String),
        capacityUsd: (json['capacityUsd'] as num).toDouble(),
      );
}

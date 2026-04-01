import 'package:burnrate/data/models/credential.dart';
import 'package:burnrate/data/models/service_type.dart';
import 'package:burnrate/data/models/usage_summary.dart';

abstract interface class BillingProvider {
  ServiceType get serviceType;
  Future<UsageSummary> fetchUsage(Credential credential);
}

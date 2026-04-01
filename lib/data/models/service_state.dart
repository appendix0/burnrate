import 'package:burnrate/data/models/usage_summary.dart';

sealed class ServiceState {
  const ServiceState();
}

class ServiceStateLoading extends ServiceState {
  const ServiceStateLoading();
}

class ServiceStateLoaded extends ServiceState {
  const ServiceStateLoaded(this.summary);
  final UsageSummary summary;
}

class ServiceStateError extends ServiceState {
  const ServiceStateError(this.message);
  final String message;
}

class ServiceStateNotConfigured extends ServiceState {
  const ServiceStateNotConfigured();
}

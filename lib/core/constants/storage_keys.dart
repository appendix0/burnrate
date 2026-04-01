class StorageKeys {
  StorageKeys._();

  // Credentials — one JSON blob per service in secure storage
  static const String credentialAnthropic = 'cred_anthropic';
  static const String credentialOpenai = 'cred_openai';
  static const String credentialGemini = 'cred_gemini';
  static const String credentialAws = 'cred_aws';
  static const String credentialOracle = 'cred_oracle';

  // Non-sensitive (SharedPreferences)
  static const String configuredServices = 'configured_services';
  static const String budgetAlerts = 'budget_alerts';
  static const String onboardingComplete = 'onboarding_complete';
  static const String lastRefreshedAt = 'last_refreshed_at';
}

class AppConfig {
  final String baseUrl;
  final bool enableLogging;

  const AppConfig({
    required this.baseUrl,
    this.enableLogging = false,
  });

  static AppConfig fromEnv() {
    const envBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://13.126.11.187:8000');
    const envLogging = String.fromEnvironment('LOG_HTTP', defaultValue: 'true');
    return AppConfig(
      baseUrl: envBaseUrl,
      enableLogging: envLogging.toLowerCase() == 'true',
    );
  }
}






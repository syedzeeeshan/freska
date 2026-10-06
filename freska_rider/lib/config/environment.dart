enum AppEnvironment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String socketUrl;
  final bool enableLogging;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.socketUrl,
    required this.enableLogging,
  });

  static late EnvironmentConfig _current;
  static EnvironmentConfig get current => _current;

  static void initialize(EnvironmentConfig config) {
    _current = config;
  }
}

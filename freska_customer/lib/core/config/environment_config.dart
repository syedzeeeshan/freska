enum Flavor { development, staging, production }

class EnvironmentConfig {
  final String apiBaseUrl;
  final String appName;
  final Flavor flavor;

  const EnvironmentConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.flavor,
  });

  static late EnvironmentConfig _instance;
  static EnvironmentConfig get instance => _instance;

  static void initialize({
    String? apiBaseUrl,
    String appName = 'Freska Customer',
    Flavor flavor = Flavor.development,
  }) {
    _instance = EnvironmentConfig(
      apiBaseUrl: apiBaseUrl ?? 'http://127.0.0.1:8088/api/v1',
      appName: appName,
      flavor: flavor,
    );
  }
}

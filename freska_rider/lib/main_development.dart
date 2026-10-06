import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'core/di/injection.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8088/api/v1',
  );
  const socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'ws://127.0.0.1:8080/app',
  );

  EnvironmentConfig.initialize(
    const EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: apiBaseUrl,
      socketUrl: socketUrl,
      enableLogging: true,
    ),
  );

  await initDependencies();

  runApp(const FreskaRiderApp());
}

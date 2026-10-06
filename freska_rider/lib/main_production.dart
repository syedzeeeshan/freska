import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'core/di/injection.dart';
import 'main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvironmentConfig.initialize(
    const EnvironmentConfig(
      environment: AppEnvironment.production,
      apiBaseUrl: 'https://api.freska.app/api/v1',
      socketUrl: 'wss://api.freska.app/app',
      enableLogging: false,
    ),
  );

  await initDependencies();

  runApp(const FreskaRiderApp());
}

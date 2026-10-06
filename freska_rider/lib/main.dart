import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/environment.dart';
import 'core/di/injection.dart';
import 'core/theme/stitch_theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'localization/l10n.dart';
import 'routing/app_router.dart';

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

  // Set default development environment
  EnvironmentConfig.initialize(
    const EnvironmentConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: apiBaseUrl,
      socketUrl: socketUrl,
      enableLogging: true,
    ),
  );

  // Initialize dependencies
  await initDependencies();

  // System UI overlay configuration
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F172A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FreskaRiderApp());
}

class FreskaRiderApp extends StatelessWidget {
  const FreskaRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Freska Rider',
        debugShowCheckedModeBanner: false,
        theme: StitchTheme.darkTheme,
        routerConfig: AppRouter.router,
        localizationsDelegates: const [
          FreskaL10n.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('hi', ''),
          Locale('kn', ''),
        ],
      ),
    );
  }
}

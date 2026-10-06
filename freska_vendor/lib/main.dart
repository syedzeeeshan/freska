import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/environment_config.dart';
import 'core/di/injection.dart';
import 'core/routes/app_router.dart';
import 'core/theme/vendor_theme.dart';
import 'features/auth/presentation/bloc/vendor_auth_bloc.dart';
import 'features/dashboard/presentation/bloc/vendor_dashboard_bloc.dart';
import 'features/earnings/presentation/bloc/vendor_earnings_bloc.dart';
import 'features/menu/presentation/bloc/vendor_menu_bloc.dart';
import 'features/orders/presentation/bloc/vendor_orders_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvironmentConfig.initialize(
    apiBaseUrl: 'http://192.168.0.4:8088/api/v1',
    flavor: Flavor.development,
  );
  await initVendorDependencies();

  runApp(const FreskaVendorApp());
}

class FreskaVendorApp extends StatelessWidget {
  const FreskaVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VendorAuthBloc>(
          create: (_) => sl<VendorAuthBloc>()..add(CheckVendorAuthSessionEvent()),
        ),
        BlocProvider<VendorDashboardBloc>(
          create: (_) => sl<VendorDashboardBloc>(),
        ),
        BlocProvider<VendorOrdersBloc>(
          create: (_) => sl<VendorOrdersBloc>(),
        ),
        BlocProvider<VendorMenuBloc>(
          create: (_) => sl<VendorMenuBloc>(),
        ),
        BlocProvider<VendorEarningsBloc>(
          create: (_) => sl<VendorEarningsBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Freska Kitchen & Store Partner',
        debugShowCheckedModeBanner: false,
        theme: VendorTheme.darkTheme(),
        routerConfig: VendorAppRouter.router,
      ),
    );
  }
}

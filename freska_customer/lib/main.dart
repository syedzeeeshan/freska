import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/environment_config.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/customer_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/orders/presentation/bloc/customer_orders_bloc.dart';
import 'features/vendor_menu/presentation/bloc/vendor_menu_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvironmentConfig.initialize();
  await initCustomerDependencies();
  runApp(const FreskaCustomerApp());
}

class FreskaCustomerApp extends StatelessWidget {
  const FreskaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerAuthBloc>(create: (_) => sl<CustomerAuthBloc>()..add(CheckAuthSessionEvent())),
        BlocProvider<HomeBloc>(create: (_) => sl<HomeBloc>()),
        BlocProvider<VendorMenuBloc>(create: (_) => sl<VendorMenuBloc>()),
        BlocProvider<CustomerCartBloc>(create: (_) => sl<CustomerCartBloc>()..add(LoadCartEvent())),
        BlocProvider<CustomerOrdersBloc>(create: (_) => sl<CustomerOrdersBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Freska Customer',
        debugShowCheckedModeBanner: false,
        theme: CustomerTheme.darkTheme(),
        routerConfig: CustomerAppRouter.router,
      ),
    );
  }
}

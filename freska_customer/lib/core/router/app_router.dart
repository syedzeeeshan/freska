import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/addresses/presentation/screens/customer_addresses_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/phone_login_screen.dart';
import '../../features/cart/presentation/screens/customer_cart_screen.dart';
import '../../features/checkout/presentation/screens/customer_checkout_screen.dart';
import '../../features/home/presentation/screens/customer_home_screen.dart';
import '../../features/orders/presentation/screens/customer_order_tracking_screen.dart';
import '../../features/orders/presentation/screens/customer_orders_history_screen.dart';
import '../../features/profile/presentation/screens/customer_profile_screen.dart';
import '../../features/search/presentation/screens/customer_search_screen.dart';
import '../../features/vendor_menu/presentation/screens/vendor_menu_screen.dart';

class CustomerAppRouter {
  CustomerAppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const CustomerPhoneLoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '+919988776655';
          return CustomerOtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          return CustomerSearchScreen(initialQuery: query);
        },
      ),
      GoRoute(
        path: '/vendor/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return VendorMenuScreen(vendorId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CustomerCartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CustomerCheckoutScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const CustomerOrdersHistoryScreen(),
      ),
      GoRoute(
        path: '/orders/:id/track',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '1') ?? 1;
          return CustomerOrderTrackingScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const CustomerAddressesScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const CustomerProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Notifications Hub')),
        ),
      ),
    ],
  );
}

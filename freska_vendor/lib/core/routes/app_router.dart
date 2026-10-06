import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/vendor_login_screen.dart';
import '../../features/auth/presentation/screens/vendor_otp_screen.dart';
import '../../features/dashboard/presentation/screens/vendor_dashboard_screen.dart';
import '../../features/earnings/presentation/screens/vendor_earnings_screen.dart';
import '../../features/menu/presentation/screens/vendor_menu_item_form_screen.dart';
import '../../features/menu/presentation/screens/vendor_menu_screen.dart';
import '../../features/orders/presentation/screens/vendor_order_detail_screen.dart';
import '../../features/orders/presentation/screens/vendor_orders_screen.dart';
import '../../features/profile/presentation/screens/vendor_profile_screen.dart';

class VendorAppRouter {
  static final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const VendorLoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '+919876500001';
          return VendorOtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          return VendorOrdersScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/orders/:id',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['id']!);
          return VendorOrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const VendorMenuScreen(),
      ),
      GoRoute(
        path: '/menu/create',
        builder: (context, state) => const VendorMenuItemFormScreen(),
      ),
      GoRoute(
        path: '/earnings',
        builder: (context, state) => const VendorEarningsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const VendorProfileScreen(),
      ),
    ],
  );
}

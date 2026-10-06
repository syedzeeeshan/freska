import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';

// Auth
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/phone_login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';

// Onboarding
import '../features/onboarding/presentation/blocs/kyc_cubit.dart';
import '../features/onboarding/presentation/blocs/profile_cubit.dart';
import '../features/onboarding/presentation/screens/bank_details_screen.dart';
import '../features/onboarding/presentation/screens/emergency_contact_screen.dart';
import '../features/onboarding/presentation/screens/kyc_document_upload_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_status_screen.dart';
import '../features/onboarding/presentation/screens/profile_setup_screen.dart';

// Dashboard & Dispatch
import '../features/dashboard/presentation/bloc/duty_bloc.dart';
import '../features/dashboard/presentation/cubit/dashboard_summary_cubit.dart';
import '../features/dashboard/presentation/screens/rider_dashboard_screen.dart';
import '../features/orders/presentation/cubit/order_offer_cubit.dart';

// Orders & Lifecycle
import '../features/orders/domain/entities/active_order_entity.dart';
import '../features/orders/presentation/cubit/order_lifecycle_bloc.dart';
import '../features/orders/presentation/cubit/voice_navigation_cubit.dart';
import '../features/orders/presentation/widgets/vendor_pickup_screen.dart';
import '../features/orders/presentation/widgets/customer_delivery_screen.dart';

// Finance & COD
import '../features/earnings/presentation/blocs/earnings_bloc.dart';
import '../features/earnings/presentation/screens/earnings_overview_screen.dart';
import '../features/cod/presentation/blocs/cod_bloc.dart';
import '../features/cod/presentation/screens/cod_management_screen.dart';

// Safety & Support
import '../features/safety/presentation/blocs/safety_bloc.dart';
import '../features/safety/presentation/screens/sos_panic_screen.dart';
import '../features/safety/presentation/screens/incident_reporting_screen.dart';
import '../features/safety/presentation/screens/insurance_card_screen.dart';
import '../features/support/presentation/blocs/support_bloc.dart';
import '../features/support/presentation/screens/support_hub_screen.dart';
import '../features/support/presentation/screens/create_ticket_screen.dart';

// Performance & Metrics
import '../features/performance/presentation/blocs/performance_cubit.dart';
import '../features/performance/presentation/screens/performance_metrics_screen.dart';

// Notifications
import '../features/notifications/presentation/blocs/notification_bloc.dart';
import '../features/notifications/presentation/screens/notification_inbox_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final phone = extra['phone'] as String? ?? '';
          final resendSeconds = extra['resendInSeconds'] as int? ?? 60;
          return OtpVerificationScreen(
            phone: phone,
            initialResendSeconds: resendSeconds,
          );
        },
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileCubit>(),
          child: const ProfileSetupScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/kyc',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final vehicleType = extra['vehicle_type'] as String? ?? 'bike';
          return BlocProvider(
            create: (_) => sl<KycCubit>(),
            child: KycDocumentUploadScreen(vehicleType: vehicleType),
          );
        },
      ),
      GoRoute(
        path: '/onboarding/bank',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileCubit>(),
          child: const BankDetailsScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/emergency',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileCubit>(),
          child: const EmergencyContactScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding/status',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<KycCubit>(),
          child: const OnboardingStatusScreen(),
        ),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<DutyBloc>()),
            BlocProvider(create: (_) => sl<DashboardSummaryCubit>()),
            BlocProvider(create: (_) => sl<OrderOfferCubit>()),
          ],
          child: const RiderDashboardScreen(),
        ),
      ),

      // Order Lifecycle
      GoRoute(
        path: '/orders/pickup',
        builder: (context, state) {
          final ActiveOrderEntity order;
          if (state.extra is ActiveOrderEntity) {
            order = state.extra as ActiveOrderEntity;
          } else {
            order = const ActiveOrderEntity(
              id: 1,
              orderNumber: 'ORD-DEMO-001',
              status: 'assigned',
              orderType: 'express',
              vendor: OrderVendorEntity(
                id: 1,
                name: 'Freska Dark Store #4',
                storeCode: 'DS-04',
                phone: '+919876543210',
                address: 'Indiranagar 100ft Rd, Bengaluru',
                latitude: 12.9716,
                longitude: 77.5946,
              ),
              customer: OrderCustomerEntity(
                name: 'Ananya Sharma',
                phone: '+919876543211',
                deliveryArea: 'Indiranagar',
                deliveryAddress: 'Flat 402, Green Glen Heights, Bengaluru',
                deliveryLatitude: 12.9780,
                deliveryLongitude: 77.6408,
              ),
              packageDetails: OrderPackageDetailsEntity(
                itemCount: 3,
                isFragile: false,
                isColdChain: true,
                items: [
                  'Fresh Milk 1L',
                  'Greek Yogurt 400g',
                  'Organic Strawberries'
                ],
              ),
              paymentMode: 'prepaid',
              codAmount: 0.0,
              isCodCollected: false,
              estimatedDistanceKm: 3.4,
              estimatedDurationMins: 14,
              totalRiderPayout: 85.0,
            );
          }

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<OrderLifecycleBloc>()),
              BlocProvider(create: (_) => sl<VoiceNavigationCubit>()),
            ],
            child: VendorPickupScreen(order: order),
          );
        },
      ),
      GoRoute(
        path: '/orders/delivery',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final order = extra['order'] as ActiveOrderEntity? ??
              const ActiveOrderEntity(
                id: 1,
                orderNumber: 'ORD-DEMO-001',
                status: 'in_transit',
                orderType: 'express',
                vendor: OrderVendorEntity(
                  id: 1,
                  name: 'Freska Dark Store #4',
                  storeCode: 'DS-04',
                  phone: '+919876543210',
                  address: 'Indiranagar 100ft Rd, Bengaluru',
                  latitude: 12.9716,
                  longitude: 77.5946,
                ),
                customer: OrderCustomerEntity(
                  name: 'Ananya Sharma',
                  phone: '+919876543211',
                  deliveryArea: 'Indiranagar',
                  deliveryAddress: 'Flat 402, Green Glen Heights, Bengaluru',
                  deliveryLatitude: 12.9780,
                  deliveryLongitude: 77.6408,
                ),
                packageDetails: OrderPackageDetailsEntity(
                  itemCount: 3,
                  isFragile: false,
                  isColdChain: true,
                  items: [
                    'Fresh Milk 1L',
                    'Greek Yogurt 400g',
                    'Organic Strawberries'
                  ],
                ),
                paymentMode: 'prepaid',
                codAmount: 0.0,
                isCodCollected: false,
                estimatedDistanceKm: 3.4,
                estimatedDurationMins: 14,
                totalRiderPayout: 85.0,
              );
          final customerAddress = extra['customerFullAddress'] as String?;
          final customerPhone = extra['customerPhone'] as String?;

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<OrderLifecycleBloc>()),
              BlocProvider(create: (_) => sl<VoiceNavigationCubit>()),
            ],
            child: CustomerDeliveryScreen(
              order: order,
              customerFullAddress: customerAddress,
              customerPhone: customerPhone,
            ),
          );
        },
      ),
      GoRoute(
        path: '/order/navigation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final order = extra['order'] as ActiveOrderEntity? ??
              const ActiveOrderEntity(
                id: 1,
                orderNumber: 'ORD-DEMO-001',
                status: 'in_transit',
                orderType: 'express',
                vendor: OrderVendorEntity(
                  id: 1,
                  name: 'Freska Dark Store #4',
                  storeCode: 'DS-04',
                  phone: '+919876543210',
                  address: 'Indiranagar 100ft Rd, Bengaluru',
                  latitude: 12.9716,
                  longitude: 77.5946,
                ),
                customer: OrderCustomerEntity(
                  name: 'Ananya Sharma',
                  phone: '+919876543211',
                  deliveryArea: 'Indiranagar',
                  deliveryAddress: 'Flat 402, Green Glen Heights, Bengaluru',
                  deliveryLatitude: 12.9780,
                  deliveryLongitude: 77.6408,
                ),
                packageDetails: OrderPackageDetailsEntity(
                  itemCount: 3,
                  isFragile: false,
                  isColdChain: true,
                  items: [
                    'Fresh Milk 1L',
                    'Greek Yogurt 400g',
                    'Organic Strawberries'
                  ],
                ),
                paymentMode: 'prepaid',
                codAmount: 0.0,
                isCodCollected: false,
                estimatedDistanceKm: 3.4,
                estimatedDurationMins: 14,
                totalRiderPayout: 85.0,
              );
          final customerAddress = extra['customerFullAddress'] as String?;
          final customerPhone = extra['customerPhone'] as String?;

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<OrderLifecycleBloc>()),
              BlocProvider(create: (_) => sl<VoiceNavigationCubit>()),
            ],
            child: CustomerDeliveryScreen(
              order: order,
              customerFullAddress: customerAddress,
              customerPhone: customerPhone,
            ),
          );
        },
      ),

      // Earnings & COD
      GoRoute(
        path: '/earnings',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<EarningsBloc>(),
          child: const EarningsOverviewScreen(),
        ),
      ),
      GoRoute(
        path: '/cod',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CodBloc>(),
          child: const CodManagementScreen(),
        ),
      ),

      // Safety & Support
      GoRoute(
        path: '/safety/sos',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SafetyBloc>(),
          child: const SosPanicScreen(),
        ),
      ),
      GoRoute(
        path: '/safety/incident',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SafetyBloc>(),
          child: const IncidentReportingScreen(),
        ),
      ),
      GoRoute(
        path: '/safety/insurance',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SafetyBloc>(),
          child: const InsuranceCardScreen(),
        ),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<SupportBloc>(),
          child: const SupportHubScreen(),
        ),
      ),
      GoRoute(
        path: '/support/create',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final category = extra['category'] as String?;
          return BlocProvider(
            create: (_) => sl<SupportBloc>(),
            child: CreateTicketScreen(initialCategory: category),
          );
        },
      ),

      // Performance
      GoRoute(
        path: '/performance',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<PerformanceCubit>(),
          child: const PerformanceMetricsScreen(),
        ),
      ),

      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<NotificationBloc>(),
          child: const NotificationInboxScreen(),
        ),
      ),
    ],
  );
}

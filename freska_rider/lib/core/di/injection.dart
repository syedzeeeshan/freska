import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';

import '../../features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/presentation/blocs/kyc_cubit.dart';
import '../../features/onboarding/presentation/blocs/profile_cubit.dart';

import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/duty_bloc.dart';
import '../../features/dashboard/presentation/cubit/dashboard_summary_cubit.dart';

import '../../features/orders/data/datasources/order_dispatch_remote_datasource.dart';
import '../../features/orders/data/datasources/order_lifecycle_remote_datasource.dart';
import '../../features/orders/data/repositories/order_dispatch_repository_impl.dart';
import '../../features/orders/domain/repositories/order_dispatch_repository.dart';
import '../../features/orders/domain/repositories/order_lifecycle_repository.dart';
import '../../features/orders/presentation/cubit/order_lifecycle_bloc.dart';
import '../../features/orders/presentation/cubit/order_offer_cubit.dart';

import '../../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../../features/earnings/domain/repositories/earnings_repository.dart';
import '../../features/earnings/presentation/blocs/earnings_bloc.dart';

import '../../features/cod/data/repositories/cod_repository_impl.dart';
import '../../features/cod/domain/repositories/cod_repository.dart';
import '../../features/cod/presentation/blocs/cod_bloc.dart';

import '../../features/safety/data/repositories/safety_repository_impl.dart';
import '../../features/safety/domain/repositories/safety_repository.dart';
import '../../features/safety/presentation/blocs/safety_bloc.dart';

import '../../features/support/data/repositories/support_repository_impl.dart';
import '../../features/support/domain/repositories/support_repository.dart';
import '../../features/support/presentation/blocs/support_bloc.dart';

import '../../features/performance/data/repositories/performance_repository_impl.dart';
import '../../features/performance/domain/repositories/performance_repository.dart';
import '../../features/performance/presentation/blocs/performance_cubit.dart';

import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/blocs/notification_bloc.dart';

import '../network/api_client.dart';
import '../services/background_geolocation_service.dart';
import '../services/offline_sync_service.dart';
import '../services/voice_navigation_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/orders/presentation/cubit/voice_navigation_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  // Core Storage & Network
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl<Dio>(), secureStorage: sl<SecureStorageService>()),
  );

  // Offline Sync Service
  sl.registerLazySingleton<OfflineSyncService>(
    () => OfflineSyncService(apiClient: sl<ApiClient>()),
  );

  // Auth DataSources & Repository
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Auth UseCases
  sl.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );

  // Auth BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      authRepository: sl<AuthRepository>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // Onboarding DataSources & Repository
  sl.registerLazySingleton<OnboardingRemoteDataSource>(
    () => OnboardingRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
        remoteDataSource: sl<OnboardingRemoteDataSource>()),
  );

  // Onboarding Cubits
  sl.registerFactory<KycCubit>(
    () => KycCubit(onboardingRepository: sl<OnboardingRepository>()),
  );

  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(onboardingRepository: sl<OnboardingRepository>()),
  );

  // Dashboard DataSources & Repository
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
        remoteDataSource: sl<DashboardRemoteDataSource>()),
  );

  // Background Geolocation Service
  sl.registerLazySingleton<BackgroundGeolocationService>(
    () => BackgroundGeolocationService(
        dashboardRepository: sl<DashboardRepository>()),
  );

  // Order Dispatch DataSources & Repository
  sl.registerLazySingleton<OrderDispatchRemoteDataSource>(
    () => OrderDispatchRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrderDispatchRepository>(
    () => OrderDispatchRepositoryImpl(
        remoteDataSource: sl<OrderDispatchRemoteDataSource>()),
  );

  // Order Lifecycle DataSources & Repository
  sl.registerLazySingleton<OrderLifecycleRemoteDataSource>(
    () => OrderLifecycleRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<OrderLifecycleRepository>(
    () => OrderLifecycleRepositoryImpl(
        remoteDataSource: sl<OrderLifecycleRemoteDataSource>()),
  );

  // Earnings Repository
  sl.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // COD Repository
  sl.registerLazySingleton<CodRepository>(
    () => CodRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Safety Repository
  sl.registerLazySingleton<SafetyRepository>(
    () => SafetyRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Support Repository
  sl.registerLazySingleton<SupportRepository>(
    () => SupportRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Performance Repository
  sl.registerLazySingleton<PerformanceRepository>(
    () => PerformanceRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Notification Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(apiClient: sl<ApiClient>()),
  );

  // Module 3 Blocs & Cubits
  sl.registerFactory<DutyBloc>(
    () => DutyBloc(
      dashboardRepository: sl<DashboardRepository>(),
      backgroundGeolocationService: sl<BackgroundGeolocationService>(),
    ),
  );

  sl.registerFactory<DashboardSummaryCubit>(
    () => DashboardSummaryCubit(dashboardRepository: sl<DashboardRepository>()),
  );

  sl.registerFactory<OrderOfferCubit>(
    () => OrderOfferCubit(
      orderDispatchRepository: sl<OrderDispatchRepository>(),
      backgroundGeolocationService: sl<BackgroundGeolocationService>(),
    ),
  );

  // Module 4 BLoCs
  sl.registerFactory<OrderLifecycleBloc>(
    () => OrderLifecycleBloc(repository: sl<OrderLifecycleRepository>()),
  );

  // Module 5 BLoCs
  sl.registerFactory<EarningsBloc>(
    () => EarningsBloc(repository: sl<EarningsRepository>()),
  );

  sl.registerFactory<CodBloc>(
    () => CodBloc(repository: sl<CodRepository>()),
  );

  // Module 6 BLoCs
  sl.registerFactory<SafetyBloc>(
    () => SafetyBloc(repository: sl<SafetyRepository>()),
  );

  sl.registerFactory<SupportBloc>(
    () => SupportBloc(repository: sl<SupportRepository>()),
  );

  // Module 7 Cubits
  sl.registerFactory<PerformanceCubit>(
    () => PerformanceCubit(repository: sl<PerformanceRepository>()),
  );

  // Module 8 BLoCs
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: sl<NotificationRepository>()),
  );

  // Voice Navigation Service & Cubit
  sl.registerLazySingleton<VoiceNavigationService>(
    () => VoiceNavigationService(),
  );

  sl.registerFactory<VoiceNavigationCubit>(
    () => VoiceNavigationCubit(voiceService: sl<VoiceNavigationService>()),
  );
}

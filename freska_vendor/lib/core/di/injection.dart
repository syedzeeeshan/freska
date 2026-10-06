import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/voice/vendor_voice_intent_engine.dart';
import '../services/voice/vendor_voice_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/vendor_auth_repository.dart';
import '../../features/auth/presentation/bloc/vendor_auth_bloc.dart';
import '../../features/dashboard/data/vendor_dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/vendor_dashboard_bloc.dart';
import '../../features/earnings/data/vendor_earnings_repository.dart';
import '../../features/earnings/presentation/bloc/vendor_earnings_bloc.dart';
import '../../features/menu/data/vendor_menu_repository.dart';
import '../../features/menu/presentation/bloc/vendor_menu_bloc.dart';
import '../../features/orders/data/vendor_orders_repository.dart';
import '../../features/orders/presentation/bloc/vendor_orders_bloc.dart';
import '../../features/profile/data/vendor_profile_repository.dart';

final sl = GetIt.instance;

Future<void> initVendorDependencies() async {
  // Core Services
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(storage: sl()));
  sl.registerLazySingleton<VendorVoiceService>(() => VendorVoiceService());
  sl.registerLazySingleton<VendorVoiceIntentEngine>(() => VendorVoiceIntentEngine(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<VendorAuthRepository>(
    () => VendorAuthRepository(apiClient: sl(), storage: sl()),
  );
  sl.registerLazySingleton<VendorDashboardRepository>(
    () => VendorDashboardRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<VendorOrdersRepository>(
    () => VendorOrdersRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<VendorMenuRepository>(
    () => VendorMenuRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<VendorEarningsRepository>(
    () => VendorEarningsRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<VendorProfileRepository>(
    () => VendorProfileRepository(apiClient: sl()),
  );

  // Blocs
  sl.registerFactory<VendorAuthBloc>(
    () => VendorAuthBloc(repository: sl()),
  );
  sl.registerFactory<VendorDashboardBloc>(
    () => VendorDashboardBloc(repository: sl()),
  );
  sl.registerFactory<VendorOrdersBloc>(
    () => VendorOrdersBloc(repository: sl()),
  );
  sl.registerFactory<VendorMenuBloc>(
    () => VendorMenuBloc(repository: sl()),
  );
  sl.registerFactory<VendorEarningsBloc>(
    () => VendorEarningsBloc(repository: sl()),
  );
}

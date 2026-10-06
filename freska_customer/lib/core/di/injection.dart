import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/voice/voice_intent_engine.dart';
import '../services/voice/voice_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/cart/data/cart_repository.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/home/data/discovery_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/orders/data/customer_orders_repository.dart';
import '../../features/orders/presentation/bloc/customer_orders_bloc.dart';
import '../../features/vendor_menu/data/vendor_menu_repository.dart';
import '../../features/vendor_menu/presentation/bloc/vendor_menu_bloc.dart';

final sl = GetIt.instance;

Future<void> initCustomerDependencies() async {
  // Core Services & Storage
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(storage: sl()));
  sl.registerLazySingleton<VoiceService>(() => VoiceService());
  sl.registerLazySingleton<CustomerVoiceIntentEngine>(() => CustomerVoiceIntentEngine(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<CustomerAuthRepository>(
    () => CustomerAuthRepository(apiClient: sl(), storage: sl()),
  );
  sl.registerLazySingleton<DiscoveryRepository>(
    () => DiscoveryRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<VendorMenuRepository>(
    () => VendorMenuRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<CustomerCartRepository>(
    () => CustomerCartRepository(apiClient: sl()),
  );
  sl.registerLazySingleton<CustomerOrdersRepository>(
    () => CustomerOrdersRepository(apiClient: sl()),
  );

  // Blocs
  sl.registerFactory<CustomerAuthBloc>(
    () => CustomerAuthBloc(repository: sl()),
  );
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(repository: sl()),
  );
  sl.registerFactory<VendorMenuBloc>(
    () => VendorMenuBloc(repository: sl()),
  );
  sl.registerFactory<CustomerCartBloc>(
    () => CustomerCartBloc(repository: sl()),
  );
  sl.registerFactory<CustomerOrdersBloc>(
    () => CustomerOrdersBloc(repository: sl()),
  );
}

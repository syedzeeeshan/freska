import 'package:flutter_test/flutter_test.dart';
import 'package:freska_vendor/core/config/environment_config.dart';
import 'package:freska_vendor/features/dashboard/presentation/bloc/vendor_dashboard_bloc.dart';
import 'package:freska_vendor/features/dashboard/data/vendor_dashboard_repository.dart';
import 'package:freska_vendor/core/network/api_client.dart';
import 'package:freska_vendor/core/storage/secure_storage_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    EnvironmentConfig.initialize(flavor: Flavor.development);
  });

  test('VendorDashboardBloc initial state is VendorDashboardInitial', () {
    final storage = SecureStorageService();
    final client = ApiClient(storage: storage);
    final repo = VendorDashboardRepository(apiClient: client);
    final bloc = VendorDashboardBloc(repository: repo);

    expect(bloc.state, isA<VendorDashboardInitial>());
    bloc.close();
  });
}

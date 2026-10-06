import 'package:flutter_test/flutter_test.dart';
import 'package:freska_customer/core/config/environment_config.dart';
import 'package:freska_customer/core/theme/customer_theme.dart';

void main() {
  test('Customer Theme tokens load properly', () {
    EnvironmentConfig.initialize(flavor: Flavor.development);
    final theme = CustomerTheme.darkTheme();
    expect(theme.scaffoldBackgroundColor, FreskaCustomerColors.bgDarkest);
    expect(theme.primaryColor, FreskaCustomerColors.primary);
  });
}

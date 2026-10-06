import 'package:flutter_test/flutter_test.dart';
import 'package:freska_vendor/core/config/environment_config.dart';
import 'package:freska_vendor/core/theme/vendor_theme.dart';

void main() {
  test('Vendor Theme tokens load properly', () {
    EnvironmentConfig.initialize(flavor: Flavor.development);
    final theme = VendorTheme.darkTheme();
    expect(theme.scaffoldBackgroundColor, FreskaVendorColors.bgDarkest);
    expect(theme.primaryColor, FreskaVendorColors.primary);
  });
}

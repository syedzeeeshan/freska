class NetworkConstants {
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Header keys
  static const String headerAuthorization = 'Authorization';
  static const String headerAccept = 'Accept';
  static const String headerContentType = 'Content-Type';
  static const String headerDeviceId = 'X-Device-Id';
  static const String headerAppVersion = 'X-App-Version';
  static const String headerPlatform = 'X-Platform';

  // Auth endpoints
  static const String endpointSendOtp = '/auth/otp/send';
  static const String endpointVerifyOtp = '/auth/otp/verify';
  static const String endpointLogout = '/auth/logout';
  static const String endpointMe = '/auth/me';

  // Duty & Telemetry
  static const String endpointDutyToggle = '/rider/duty/toggle';
  static const String endpointDashboardSummary = '/rider/dashboard/summary';
  static const String endpointLocationHeartbeat = '/rider/location';

  // Order Dispatch & Offers
  static const String endpointActiveOrder = '/rider/orders/active';
  static String endpointAcceptOrder(int orderId) =>
      '/rider/orders/$orderId/accept';
  static String endpointRejectOrder(int orderId) =>
      '/rider/orders/$orderId/reject';

  // Order Fulfillment Lifecycle (Module 4)
  static String endpointArriveVendor(int orderId) =>
      '/rider/orders/$orderId/arrive-vendor';
  static String endpointPickupOrder(int orderId) =>
      '/rider/orders/$orderId/pickup';
  static String endpointArriveCustomer(int orderId) =>
      '/rider/orders/$orderId/arrive-customer';
  static String endpointConfirmDelivery(int orderId) =>
      '/rider/orders/$orderId/confirm-delivery';
}

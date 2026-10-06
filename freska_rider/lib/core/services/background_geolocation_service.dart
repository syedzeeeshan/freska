import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:freska_rider/features/dashboard/domain/repositories/dashboard_repository.dart';

class BackgroundGeolocationService {
  final DashboardRepository dashboardRepository;
  Timer? _heartbeatTimer;
  bool _isTracking = false;

  BackgroundGeolocationService({required this.dashboardRepository});

  bool get isTracking => _isTracking;

  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  void startTracking({Duration interval = const Duration(seconds: 20)}) {
    if (_isTracking) return;
    _isTracking = true;

    // Send immediate heartbeat
    _sendHeartbeat();

    // Schedule recurring heartbeat every 20s
    _heartbeatTimer = Timer.periodic(interval, (_) => _sendHeartbeat());
  }

  void stopTracking() {
    _isTracking = false;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendHeartbeat() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) return;

      await dashboardRepository.sendLocationHeartbeat(
        latitude: position.latitude,
        longitude: position.longitude,
        heading: position.heading,
        speed: position.speed,
        batteryPercentage: null,
        isMock: position.isMocked,
      );
    } catch (_) {
      // Ignored: Silent network retry on subsequent interval
    }
  }

  void dispose() {
    stopTracking();
  }
}

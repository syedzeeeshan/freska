import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/core/services/background_geolocation_service.dart';
import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';
import 'package:freska_rider/features/orders/domain/repositories/order_dispatch_repository.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_cubit.dart';
import 'package:freska_rider/features/orders/presentation/cubit/order_offer_state.dart';

class MockOrderDispatchRepository extends Mock
    implements OrderDispatchRepository {}

class MockBackgroundGeolocationService extends Mock
    implements BackgroundGeolocationService {}

void main() {
  late MockOrderDispatchRepository mockRepo;
  late MockBackgroundGeolocationService mockGeoService;
  late OrderOfferCubit cubit;

  final tOffer = OrderOfferEntity(
    id: 1,
    orderId: 101,
    orderNumber: 'FSK-2026-90001',
    vendorName: 'Freska Hub Indiranagar',
    vendorAddress: '100 Feet Rd, Indiranagar',
    vendorLatitude: 12.978369,
    vendorLongitude: 77.640835,
    deliveryArea: 'Indiranagar 1st Stage',
    estimatedDistanceKm: 3.2,
    estimatedDurationMins: 15,
    totalRiderPayout: 60.0,
    isColdChain: false,
    isFragile: false,
    itemCount: 3,
    paymentMode: 'prepaid',
    codAmount: 0.0,
    offeredAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(seconds: 30)),
    remainingSeconds: 30,
  );

  final tPosition = Position(
    latitude: 12.971598,
    longitude: 77.594562,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 900.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 1.0,
    speed: 0.0,
    speedAccuracy: 1.0,
    isMocked: false,
  );

  setUp(() {
    mockRepo = MockOrderDispatchRepository();
    mockGeoService = MockBackgroundGeolocationService();
    cubit = OrderOfferCubit(
      orderDispatchRepository: mockRepo,
      backgroundGeolocationService: mockGeoService,
    );
  });

  tearDown(() => cubit.close());

  test('initial state is idle', () {
    expect(cubit.state, equals(const OrderOfferState()));
  });

  group('acceptCurrentOffer', () {
    blocTest<OrderOfferCubit, OrderOfferState>(
      'emits [accepting, accepted] when order offer is accepted',
      build: () {
        when(() => mockGeoService.getCurrentPosition())
            .thenAnswer((_) async => tPosition);
        when(() => mockRepo.acceptOrder(
              orderId: 101,
              latitude: tPosition.latitude,
              longitude: tPosition.longitude,
            )).thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => OrderOfferState(
        status: OrderOfferStatus.active,
        offer: tOffer,
        remainingSeconds: 25,
      ),
      act: (c) => c.acceptCurrentOffer(),
      expect: () => [
        OrderOfferState(
          status: OrderOfferStatus.accepting,
          offer: tOffer,
          remainingSeconds: 25,
        ),
        OrderOfferState(
          status: OrderOfferStatus.accepted,
          offer: tOffer,
          remainingSeconds: 25,
        ),
      ],
    );
  });

  group('rejectCurrentOffer', () {
    blocTest<OrderOfferCubit, OrderOfferState>(
      'emits [rejecting, rejected] when order offer is declined',
      build: () {
        when(() => mockRepo.rejectOrder(
              orderId: 101,
              reason: 'Vehicle puncture / breakdown',
            )).thenAnswer((_) async => true);
        return cubit;
      },
      seed: () => OrderOfferState(
        status: OrderOfferStatus.active,
        offer: tOffer,
        remainingSeconds: 25,
      ),
      act: (c) => c.rejectCurrentOffer('Vehicle puncture / breakdown'),
      expect: () => [
        OrderOfferState(
          status: OrderOfferStatus.rejecting,
          offer: tOffer,
          remainingSeconds: 25,
        ),
        OrderOfferState(
          status: OrderOfferStatus.rejected,
          offer: tOffer,
          remainingSeconds: 25,
        ),
      ],
    );
  });
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_rider/core/services/background_geolocation_service.dart';
import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';
import 'package:freska_rider/features/orders/domain/repositories/order_dispatch_repository.dart';
import 'order_offer_state.dart';

class OrderOfferCubit extends Cubit<OrderOfferState> {
  final OrderDispatchRepository orderDispatchRepository;
  final BackgroundGeolocationService backgroundGeolocationService;
  Timer? _countdownTimer;

  OrderOfferCubit({
    required this.orderDispatchRepository,
    required this.backgroundGeolocationService,
  }) : super(const OrderOfferState());

  void startOffer(OrderOfferEntity offer) {
    _countdownTimer?.cancel();

    final initialSeconds =
        offer.remainingSeconds > 0 ? offer.remainingSeconds : 30;

    emit(state.copyWith(
      status: OrderOfferStatus.active,
      offer: offer,
      remainingSeconds: initialSeconds,
      errorMessage: null,
    ));

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nextSeconds = state.remainingSeconds - 1;
      if (nextSeconds <= 0) {
        timer.cancel();
        emit(state.copyWith(
          status: OrderOfferStatus.expired,
          remainingSeconds: 0,
        ));
      } else {
        emit(state.copyWith(remainingSeconds: nextSeconds));
      }
    });
  }

  Future<void> acceptCurrentOffer() async {
    final offer = state.offer;
    if (offer == null || state.remainingSeconds <= 0) {
      emit(state.copyWith(
        status: OrderOfferStatus.failure,
        errorMessage: 'This delivery offer has already expired.',
      ));
      return;
    }

    _countdownTimer?.cancel();
    emit(state.copyWith(status: OrderOfferStatus.accepting));

    try {
      final position = await backgroundGeolocationService.getCurrentPosition();
      final lat = position?.latitude ?? offer.vendorLatitude;
      final lng = position?.longitude ?? offer.vendorLongitude;

      await orderDispatchRepository.acceptOrder(
        orderId: offer.orderId,
        latitude: lat,
        longitude: lng,
      );

      emit(state.copyWith(status: OrderOfferStatus.accepted));
    } catch (e) {
      emit(state.copyWith(
        status: OrderOfferStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> rejectCurrentOffer(String reason) async {
    final offer = state.offer;
    if (offer == null) return;

    _countdownTimer?.cancel();
    emit(state.copyWith(status: OrderOfferStatus.rejecting));

    try {
      await orderDispatchRepository.rejectOrder(
        orderId: offer.orderId,
        reason: reason,
      );

      emit(state.copyWith(status: OrderOfferStatus.rejected));
    } catch (e) {
      emit(state.copyWith(
        status: OrderOfferStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  void dismissOffer() {
    _countdownTimer?.cancel();
    emit(const OrderOfferState(status: OrderOfferStatus.idle));
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}

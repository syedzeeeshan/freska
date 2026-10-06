import 'package:equatable/equatable.dart';
import 'package:freska_rider/features/orders/domain/entities/order_offer_entity.dart';

enum OrderOfferStatus {
  idle,
  active,
  accepting,
  accepted,
  rejecting,
  rejected,
  expired,
  failure,
}

class OrderOfferState extends Equatable {
  final OrderOfferStatus status;
  final OrderOfferEntity? offer;
  final int remainingSeconds;
  final String? errorMessage;

  const OrderOfferState({
    this.status = OrderOfferStatus.idle,
    this.offer,
    this.remainingSeconds = 30,
    this.errorMessage,
  });

  OrderOfferState copyWith({
    OrderOfferStatus? status,
    OrderOfferEntity? offer,
    int? remainingSeconds,
    String? errorMessage,
  }) {
    return OrderOfferState(
      status: status ?? this.status,
      offer: offer ?? this.offer,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, offer, remainingSeconds, errorMessage];
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_customer/features/cart/data/cart_repository.dart';

abstract class CustomerCartEvent extends Equatable {
  const CustomerCartEvent();
  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CustomerCartEvent {}

class UpdateCartItemQuantityEvent extends CustomerCartEvent {
  final int itemId;
  final int quantity;
  const UpdateCartItemQuantityEvent({required this.itemId, required this.quantity});
  @override
  List<Object?> get props => [itemId, quantity];
}

class ClearCartEvent extends CustomerCartEvent {}

abstract class CustomerCartState extends Equatable {
  const CustomerCartState();
  @override
  List<Object?> get props => [];
}

class CustomerCartInitial extends CustomerCartState {}

class CustomerCartLoading extends CustomerCartState {}

class CustomerCartLoaded extends CustomerCartState {
  final Map<String, dynamic> cart;
  const CustomerCartLoaded(this.cart);
  @override
  List<Object?> get props => [cart];
}

class CustomerCartError extends CustomerCartState {
  final String message;
  const CustomerCartError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerCartBloc extends Bloc<CustomerCartEvent, CustomerCartState> {
  final CustomerCartRepository _repository;

  CustomerCartBloc({required CustomerCartRepository repository})
      : _repository = repository,
        super(CustomerCartInitial()) {
    on<LoadCartEvent>((event, emit) async {
      emit(CustomerCartLoading());
      try {
        final cart = await _repository.getCart();
        emit(CustomerCartLoaded(cart));
      } catch (e) {
        emit(CustomerCartError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateCartItemQuantityEvent>((event, emit) async {
      try {
        final updatedCart = await _repository.updateQuantity(
          itemId: event.itemId,
          quantity: event.quantity,
        );
        emit(CustomerCartLoaded(updatedCart));
      } catch (e) {
        emit(CustomerCartError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ClearCartEvent>((event, emit) async {
      await _repository.clearCart();
      emit(const CustomerCartLoaded({
        'items': [],
        'item_count': 0,
        'subtotal': 0.0,
        'total_amount': 0.0,
      }));
    });
  }
}

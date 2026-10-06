import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_customer/features/orders/data/customer_orders_repository.dart';

abstract class CustomerOrdersEvent extends Equatable {
  const CustomerOrdersEvent();
  @override
  List<Object?> get props => [];
}

class LoadCustomerOrdersEvent extends CustomerOrdersEvent {}

abstract class CustomerOrdersState extends Equatable {
  const CustomerOrdersState();
  @override
  List<Object?> get props => [];
}

class CustomerOrdersInitial extends CustomerOrdersState {}

class CustomerOrdersLoading extends CustomerOrdersState {}

class CustomerOrdersLoaded extends CustomerOrdersState {
  final List<Map<String, dynamic>> orders;
  const CustomerOrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class CustomerOrdersError extends CustomerOrdersState {
  final String message;
  const CustomerOrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

class CustomerOrdersBloc extends Bloc<CustomerOrdersEvent, CustomerOrdersState> {
  final CustomerOrdersRepository _repository;

  CustomerOrdersBloc({required CustomerOrdersRepository repository})
      : _repository = repository,
        super(CustomerOrdersInitial()) {
    on<LoadCustomerOrdersEvent>((event, emit) async {
      emit(CustomerOrdersLoading());
      try {
        final orders = await _repository.getOrders();
        emit(CustomerOrdersLoaded(orders));
      } catch (e) {
        emit(CustomerOrdersError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

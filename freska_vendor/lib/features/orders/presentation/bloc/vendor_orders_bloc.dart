import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_vendor/features/orders/data/vendor_orders_repository.dart';

abstract class VendorOrdersEvent extends Equatable {
  const VendorOrdersEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorOrdersEvent extends VendorOrdersEvent {
  final String? statusFilter;
  const LoadVendorOrdersEvent({this.statusFilter});
  @override
  List<Object?> get props => [statusFilter];
}

class UpdateOrderStatusEvent extends VendorOrdersEvent {
  final int orderId;
  final String newStatus;
  const UpdateOrderStatusEvent({required this.orderId, required this.newStatus});
  @override
  List<Object?> get props => [orderId, newStatus];
}

abstract class VendorOrdersState extends Equatable {
  const VendorOrdersState();
  @override
  List<Object?> get props => [];
}

class VendorOrdersInitial extends VendorOrdersState {}

class VendorOrdersLoading extends VendorOrdersState {}

class VendorOrdersLoaded extends VendorOrdersState {
  final List<Map<String, dynamic>> orders;
  final String? activeFilter;
  const VendorOrdersLoaded({required this.orders, this.activeFilter});
  @override
  List<Object?> get props => [orders, activeFilter];
}

class VendorOrdersError extends VendorOrdersState {
  final String message;
  const VendorOrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorOrdersBloc extends Bloc<VendorOrdersEvent, VendorOrdersState> {
  final VendorOrdersRepository _repository;

  VendorOrdersBloc({required VendorOrdersRepository repository})
      : _repository = repository,
        super(VendorOrdersInitial()) {
    on<LoadVendorOrdersEvent>((event, emit) async {
      emit(VendorOrdersLoading());
      try {
        final orders = await _repository.getOrders(status: event.statusFilter);
        emit(VendorOrdersLoaded(orders: orders, activeFilter: event.statusFilter));
      } catch (e) {
        emit(VendorOrdersError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<UpdateOrderStatusEvent>((event, emit) async {
      try {
        await _repository.updateOrderStatus(orderId: event.orderId, status: event.newStatus);
        final orders = await _repository.getOrders();
        emit(VendorOrdersLoaded(orders: orders));
      } catch (e) {
        emit(VendorOrdersError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_customer/features/vendor_menu/data/vendor_menu_repository.dart';

abstract class VendorMenuEvent extends Equatable {
  const VendorMenuEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorMenuEvent extends VendorMenuEvent {
  final int vendorId;
  const LoadVendorMenuEvent(this.vendorId);
  @override
  List<Object?> get props => [vendorId];
}

abstract class VendorMenuState extends Equatable {
  const VendorMenuState();
  @override
  List<Object?> get props => [];
}

class VendorMenuInitial extends VendorMenuState {}

class VendorMenuLoading extends VendorMenuState {}

class VendorMenuLoaded extends VendorMenuState {
  final Map<String, dynamic> vendor;
  const VendorMenuLoaded(this.vendor);
  @override
  List<Object?> get props => [vendor];
}

class VendorMenuError extends VendorMenuState {
  final String message;
  const VendorMenuError(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorMenuBloc extends Bloc<VendorMenuEvent, VendorMenuState> {
  final VendorMenuRepository _repository;

  VendorMenuBloc({required VendorMenuRepository repository})
      : _repository = repository,
        super(VendorMenuInitial()) {
    on<LoadVendorMenuEvent>((event, emit) async {
      emit(VendorMenuLoading());
      try {
        final data = await _repository.getVendorDetails(event.vendorId);
        emit(VendorMenuLoaded(data));
      } catch (e) {
        emit(VendorMenuError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

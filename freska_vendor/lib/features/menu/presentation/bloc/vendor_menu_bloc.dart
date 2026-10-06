import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_vendor/features/menu/data/vendor_menu_repository.dart';

abstract class VendorMenuEvent extends Equatable {
  const VendorMenuEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorMenuItemsEvent extends VendorMenuEvent {}

class ToggleItemAvailabilityEvent extends VendorMenuEvent {
  final int itemId;
  const ToggleItemAvailabilityEvent(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class DeleteMenuItemEvent extends VendorMenuEvent {
  final int itemId;
  const DeleteMenuItemEvent(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

abstract class VendorMenuState extends Equatable {
  const VendorMenuState();
  @override
  List<Object?> get props => [];
}

class VendorMenuInitial extends VendorMenuState {}

class VendorMenuLoading extends VendorMenuState {}

class VendorMenuLoaded extends VendorMenuState {
  final List<Map<String, dynamic>> items;
  const VendorMenuLoaded(this.items);
  @override
  List<Object?> get props => [items];
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
    on<LoadVendorMenuItemsEvent>((event, emit) async {
      emit(VendorMenuLoading());
      try {
        final items = await _repository.getMenuItems();
        emit(VendorMenuLoaded(items));
      } catch (e) {
        emit(VendorMenuError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ToggleItemAvailabilityEvent>((event, emit) async {
      try {
        await _repository.toggleAvailability(event.itemId);
        final items = await _repository.getMenuItems();
        emit(VendorMenuLoaded(items));
      } catch (e) {
        emit(VendorMenuError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<DeleteMenuItemEvent>((event, emit) async {
      try {
        await _repository.deleteMenuItem(event.itemId);
        final items = await _repository.getMenuItems();
        emit(VendorMenuLoaded(items));
      } catch (e) {
        emit(VendorMenuError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

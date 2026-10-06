import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_vendor/features/dashboard/data/vendor_dashboard_repository.dart';

abstract class VendorDashboardEvent extends Equatable {
  const VendorDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorDashboardEvent extends VendorDashboardEvent {}

class ToggleStoreStatusEvent extends VendorDashboardEvent {}

abstract class VendorDashboardState extends Equatable {
  const VendorDashboardState();
  @override
  List<Object?> get props => [];
}

class VendorDashboardInitial extends VendorDashboardState {}

class VendorDashboardLoading extends VendorDashboardState {}

class VendorDashboardLoaded extends VendorDashboardState {
  final Map<String, dynamic> data;
  const VendorDashboardLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class VendorDashboardError extends VendorDashboardState {
  final String message;
  const VendorDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorDashboardBloc extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final VendorDashboardRepository _repository;

  VendorDashboardBloc({required VendorDashboardRepository repository})
      : _repository = repository,
        super(VendorDashboardInitial()) {
    on<LoadVendorDashboardEvent>((event, emit) async {
      emit(VendorDashboardLoading());
      try {
        final summary = await _repository.getDashboardSummary();
        emit(VendorDashboardLoaded(summary));
      } catch (e) {
        emit(VendorDashboardError(e.toString().replaceAll('Exception: ', '')));
      }
    });

    on<ToggleStoreStatusEvent>((event, emit) async {
      try {
        await _repository.toggleStoreStatus();
        final summary = await _repository.getDashboardSummary();
        emit(VendorDashboardLoaded(summary));
      } catch (e) {
        emit(VendorDashboardError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_vendor/features/earnings/data/vendor_earnings_repository.dart';

abstract class VendorEarningsEvent extends Equatable {
  const VendorEarningsEvent();
  @override
  List<Object?> get props => [];
}

class LoadVendorEarningsEvent extends VendorEarningsEvent {}

abstract class VendorEarningsState extends Equatable {
  const VendorEarningsState();
  @override
  List<Object?> get props => [];
}

class VendorEarningsInitial extends VendorEarningsState {}

class VendorEarningsLoading extends VendorEarningsState {}

class VendorEarningsLoaded extends VendorEarningsState {
  final Map<String, dynamic> data;
  const VendorEarningsLoaded(this.data);
  @override
  List<Object?> get props => [data];
}

class VendorEarningsError extends VendorEarningsState {
  final String message;
  const VendorEarningsError(this.message);
  @override
  List<Object?> get props => [message];
}

class VendorEarningsBloc extends Bloc<VendorEarningsEvent, VendorEarningsState> {
  final VendorEarningsRepository _repository;

  VendorEarningsBloc({required VendorEarningsRepository repository})
      : _repository = repository,
        super(VendorEarningsInitial()) {
    on<LoadVendorEarningsEvent>((event, emit) async {
      emit(VendorEarningsLoading());
      try {
        final data = await _repository.getEarnings();
        emit(VendorEarningsLoaded(data));
      } catch (e) {
        emit(VendorEarningsError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freska_customer/features/home/data/discovery_repository.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final String? selectedCategory;
  const LoadHomeDataEvent({this.selectedCategory});
  @override
  List<Object?> get props => [selectedCategory];
}

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> vendors;
  final String? selectedCategory;

  const HomeLoaded({
    required this.categories,
    required this.vendors,
    this.selectedCategory,
  });

  @override
  List<Object?> get props => [categories, vendors, selectedCategory];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DiscoveryRepository _repository;

  HomeBloc({required DiscoveryRepository repository})
      : _repository = repository,
        super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final categories = await _repository.getCategories();
        final vendors = await _repository.getVendors(category: event.selectedCategory);
        emit(HomeLoaded(
          categories: categories,
          vendors: vendors,
          selectedCategory: event.selectedCategory,
        ));
      } catch (e) {
        emit(HomeError(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}

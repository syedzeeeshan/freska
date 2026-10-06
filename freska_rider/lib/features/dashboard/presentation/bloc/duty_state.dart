import 'package:equatable/equatable.dart';

enum DutyStatus { initial, toggling, success, failure }

class DutyState extends Equatable {
  final bool isOnline;
  final DutyStatus status;
  final String? errorMessage;

  const DutyState({
    this.isOnline = false,
    this.status = DutyStatus.initial,
    this.errorMessage,
  });

  DutyState copyWith({
    bool? isOnline,
    DutyStatus? status,
    String? errorMessage,
  }) {
    return DutyState(
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isOnline, status, errorMessage];
}

import 'package:equatable/equatable.dart';

abstract class DutyEvent extends Equatable {
  const DutyEvent();

  @override
  List<Object?> get props => [];
}

class ToggleDutyEvent extends DutyEvent {
  final bool isOnline;

  const ToggleDutyEvent({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

class SetInitialDutyEvent extends DutyEvent {
  final bool isOnline;

  const SetInitialDutyEvent({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}

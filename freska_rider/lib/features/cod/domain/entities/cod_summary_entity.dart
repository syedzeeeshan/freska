import 'package:equatable/equatable.dart';

class CodSummaryEntity extends Equatable {
  final double currentCashInHand;
  final double maxCashLimit;
  final int pendingSettlementCount;
  final bool isBlockedFromAssignments;
  final double headroomAvailable;

  const CodSummaryEntity({
    required this.currentCashInHand,
    required this.maxCashLimit,
    required this.pendingSettlementCount,
    required this.isBlockedFromAssignments,
    required this.headroomAvailable,
  });

  @override
  List<Object?> get props => [
        currentCashInHand,
        maxCashLimit,
        pendingSettlementCount,
        isBlockedFromAssignments,
        headroomAvailable,
      ];
}

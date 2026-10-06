import 'package:equatable/equatable.dart';

class KycEntity extends Equatable {
  final String kycStatus;
  final String? rejectionReason;
  final String? reviewedAt;
  final String? vehicleType;
  final String? vehicleNumber;
  final String? licenseNumber;
  final String? licenseExpiry;

  const KycEntity({
    required this.kycStatus,
    this.rejectionReason,
    this.reviewedAt,
    this.vehicleType,
    this.vehicleNumber,
    this.licenseNumber,
    this.licenseExpiry,
  });

  bool get isVerified => kycStatus == 'verified';
  bool get isSubmitted => kycStatus == 'submitted';
  bool get isRejected => kycStatus == 'rejected';
  bool get isPending => kycStatus == 'pending';

  @override
  List<Object?> get props => [
        kycStatus,
        rejectionReason,
        reviewedAt,
        vehicleType,
        vehicleNumber,
        licenseNumber,
        licenseExpiry,
      ];
}

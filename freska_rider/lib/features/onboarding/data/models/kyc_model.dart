import '../../domain/entities/kyc_entity.dart';

class KycModel extends KycEntity {
  const KycModel({
    required super.kycStatus,
    super.rejectionReason,
    super.reviewedAt,
    super.vehicleType,
    super.vehicleNumber,
    super.licenseNumber,
    super.licenseExpiry,
  });

  factory KycModel.fromJson(Map<String, dynamic> json) {
    return KycModel(
      kycStatus: json['kyc_status']?.toString() ?? 'pending',
      rejectionReason: json['rejection_reason']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      vehicleType: json['vehicle_type']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      licenseNumber: json['license_number']?.toString(),
      licenseExpiry: json['license_expiry']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kyc_status': kycStatus,
      'rejection_reason': rejectionReason,
      'reviewed_at': reviewedAt,
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
    };
  }
}

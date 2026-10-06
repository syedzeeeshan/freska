import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String? name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role;
  final String status;
  final String kycStatus;
  final bool isOnline;
  final double ratingAverage;
  final int completedDeliveriesCount;
  final String tier;
  final bool phoneVerified;

  const UserEntity({
    required this.id,
    this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.status,
    required this.kycStatus,
    required this.isOnline,
    required this.ratingAverage,
    required this.completedDeliveriesCount,
    required this.tier,
    required this.phoneVerified,
  });

  bool get isKycVerified => kycStatus == 'verified';
  bool get isPendingKyc => kycStatus == 'pending' || kycStatus == 'submitted';

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatarUrl,
        role,
        status,
        kycStatus,
        isOnline,
        ratingAverage,
        completedDeliveriesCount,
        tier,
        phoneVerified,
      ];
}

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.name,
    required super.phone,
    super.email,
    super.avatarUrl,
    required super.role,
    required super.status,
    required super.kycStatus,
    required super.isOnline,
    required super.ratingAverage,
    required super.completedDeliveriesCount,
    required super.tier,
    required super.phoneVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString(),
      phone: json['phone'].toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      role: json['role']?.toString() ?? 'rider',
      status: json['status']?.toString() ?? 'pending_kyc',
      kycStatus: json['kyc_status']?.toString() ?? 'pending',
      isOnline: json['is_online'] == true,
      ratingAverage: (json['rating_average'] is num)
          ? (json['rating_average'] as num).toDouble()
          : 5.0,
      completedDeliveriesCount: json['completed_deliveries_count'] is int
          ? json['completed_deliveries_count']
          : 0,
      tier: json['tier']?.toString() ?? 'bronze',
      phoneVerified: json['phone_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'status': status,
      'kyc_status': kycStatus,
      'is_online': isOnline,
      'rating_average': ratingAverage,
      'completed_deliveries_count': completedDeliveriesCount,
      'tier': tier,
      'phone_verified': phoneVerified,
    };
  }
}

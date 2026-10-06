class OtpResponseModel {
  final String phone;
  final int resendInSeconds;

  OtpResponseModel({
    required this.phone,
    required this.resendInSeconds,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      phone: json['phone'] as String,
      resendInSeconds: (json['resend_in_seconds'] as num?)?.toInt() ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'resend_in_seconds': resendInSeconds,
    };
  }
}

class TokenModel {
  final String token;

  TokenModel({required this.token});

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
    };
  }
}

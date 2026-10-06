import '../../domain/entities/bank_details_entity.dart';

class BankDetailsModel extends BankDetailsEntity {
  const BankDetailsModel({
    required super.bankAccountHolder,
    required super.bankName,
    required super.bankAccountNumber,
    required super.bankIfscCode,
    super.bankUpiId,
    required super.bankVerified,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) {
    return BankDetailsModel(
      bankAccountHolder: json['bank_account_holder']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      bankAccountNumber: json['bank_account_number']?.toString() ?? '',
      bankIfscCode: json['bank_ifsc_code']?.toString() ?? '',
      bankUpiId: json['bank_upi_id']?.toString(),
      bankVerified: json['bank_verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_account_holder': bankAccountHolder,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_ifsc_code': bankIfscCode,
      'bank_upi_id': bankUpiId,
      'bank_verified': bankVerified,
    };
  }
}

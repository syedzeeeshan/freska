import 'package:equatable/equatable.dart';

class BankDetailsEntity extends Equatable {
  final String bankAccountHolder;
  final String bankName;
  final String bankAccountNumber;
  final String bankIfscCode;
  final String? bankUpiId;
  final bool bankVerified;

  const BankDetailsEntity({
    required this.bankAccountHolder,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankIfscCode,
    this.bankUpiId,
    required this.bankVerified,
  });

  @override
  List<Object?> get props => [
        bankAccountHolder,
        bankName,
        bankAccountNumber,
        bankIfscCode,
        bankUpiId,
        bankVerified,
      ];
}

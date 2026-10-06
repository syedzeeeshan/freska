import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/bank_details_model.dart';
import '../models/kyc_model.dart';

abstract class OnboardingRemoteDataSource {
  Future<String> uploadProfilePhoto(File photoFile);

  Future<KycModel> submitKyc({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    required String licenseExpiry,
    required File licenseFront,
    required File licenseBack,
    required File rcBook,
    required String idProofType,
    required String idProofNumber,
    required File idProofDocument,
  });

  Future<KycModel> getKycStatus();

  Future<BankDetailsModel> updateBankDetails({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  });

  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  });
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<String> uploadProfilePhoto(File photoFile) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(photoFile.path),
    });

    final response = await apiClient.post(
      '/rider/profile/photo',
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return data['avatar_url'] as String;
  }

  @override
  Future<KycModel> submitKyc({
    required String vehicleType,
    required String vehicleNumber,
    required String licenseNumber,
    required String licenseExpiry,
    required File licenseFront,
    required File licenseBack,
    required File rcBook,
    required String idProofType,
    required String idProofNumber,
    required File idProofDocument,
  }) async {
    final formData = FormData.fromMap({
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNumber,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry,
      'license_front': await MultipartFile.fromFile(licenseFront.path),
      'license_back': await MultipartFile.fromFile(licenseBack.path),
      'rc_book': await MultipartFile.fromFile(rcBook.path),
      'id_proof_type': idProofType,
      'id_proof_number': idProofNumber,
      'id_proof_document': await MultipartFile.fromFile(idProofDocument.path),
    });

    final response = await apiClient.post(
      '/rider/documents',
      data: formData,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return KycModel.fromJson(data);
  }

  @override
  Future<KycModel> getKycStatus() async {
    final response = await apiClient.get('/rider/documents/status');
    final data = response.data['data'] as Map<String, dynamic>;
    return KycModel.fromJson(data);
  }

  @override
  Future<BankDetailsModel> updateBankDetails({
    required String accountHolder,
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    final response = await apiClient.put(
      '/rider/bank-details',
      data: {
        'bank_account_holder': accountHolder,
        'bank_name': bankName,
        'bank_account_number': accountNumber,
        'bank_ifsc_code': ifscCode,
        'bank_upi_id': upiId,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return BankDetailsModel.fromJson(data);
  }

  @override
  Future<void> updateEmergencyContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    await apiClient.put(
      '/rider/emergency-contact',
      data: {
        'emergency_contact_name': name,
        'emergency_contact_phone': phone,
        'emergency_contact_relation': relation,
      },
    );
  }
}

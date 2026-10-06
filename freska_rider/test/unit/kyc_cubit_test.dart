import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/features/onboarding/domain/entities/kyc_entity.dart';
import 'package:freska_rider/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:freska_rider/features/onboarding/presentation/blocs/kyc_cubit.dart';
import 'package:freska_rider/features/onboarding/presentation/blocs/kyc_state.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockFile extends Mock implements File {}

void main() {
  late MockOnboardingRepository mockRepo;
  late KycCubit kycCubit;

  const tKyc = KycEntity(
    kycStatus: 'submitted',
    vehicleType: 'bike',
    vehicleNumber: 'KA01AB1234',
    licenseNumber: 'DL1420110012345',
  );

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockRepo = MockOnboardingRepository();
    kycCubit = KycCubit(onboardingRepository: mockRepo);
  });

  tearDown(() => kycCubit.close());

  test('initial state is KycInitial', () {
    expect(kycCubit.state, equals(KycInitial()));
  });

  group('checkKycStatus', () {
    blocTest<KycCubit, KycState>(
      'emits [KycLoading, KycStatusLoaded] on successful status check',
      build: () {
        when(() => mockRepo.getKycStatus()).thenAnswer((_) async => tKyc);
        return kycCubit;
      },
      act: (cubit) => cubit.checkKycStatus(),
      expect: () => [
        KycLoading(),
        const KycStatusLoaded(kyc: tKyc),
      ],
    );
  });

  group('submitKyc', () {
    final mockFile = MockFile();

    blocTest<KycCubit, KycState>(
      'emits [KycLoading, KycSubmittedSuccess] on successful document upload',
      build: () {
        when(() => mockRepo.submitKyc(
              vehicleType: any(named: 'vehicleType'),
              vehicleNumber: any(named: 'vehicleNumber'),
              licenseNumber: any(named: 'licenseNumber'),
              licenseExpiry: any(named: 'licenseExpiry'),
              licenseFront: any(named: 'licenseFront'),
              licenseBack: any(named: 'licenseBack'),
              rcBook: any(named: 'rcBook'),
              idProofType: any(named: 'idProofType'),
              idProofNumber: any(named: 'idProofNumber'),
              idProofDocument: any(named: 'idProofDocument'),
            )).thenAnswer((_) async => tKyc);
        return kycCubit;
      },
      act: (cubit) => cubit.submitKyc(
        vehicleType: 'bike',
        vehicleNumber: 'KA01AB1234',
        licenseNumber: 'DL1420110012345',
        licenseExpiry: '2028-12-31',
        licenseFront: mockFile,
        licenseBack: mockFile,
        rcBook: mockFile,
        idProofType: 'aadhaar',
        idProofNumber: '123456789012',
        idProofDocument: mockFile,
      ),
      expect: () => [
        KycLoading(),
        const KycSubmittedSuccess(kyc: tKyc),
      ],
    );
  });
}

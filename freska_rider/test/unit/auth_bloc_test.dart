import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/core/storage/secure_storage_service.dart';
import 'package:freska_rider/features/auth/domain/entities/user_entity.dart';
import 'package:freska_rider/features/auth/domain/repositories/auth_repository.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_event.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorage;
  late AuthBloc authBloc;

  const tUser = UserEntity(
    id: 14,
    phone: '+919876543210',
    name: 'Arjun Sharma',
    role: 'rider',
    status: 'active',
    kycStatus: 'verified',
    isOnline: true,
    ratingAverage: 5.0,
    completedDeliveriesCount: 10,
    tier: 'bronze',
    phoneVerified: true,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    authBloc = AuthBloc(
      authRepository: mockAuthRepository,
      secureStorage: mockSecureStorage,
    );
  });

  tearDown(() => authBloc.close());

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  group('SendOtpEvent', () {
    const tPhone = '+919876543210';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, OtpSentState] when OTP dispatch succeeds',
      build: () {
        when(() => mockAuthRepository.sendOtp(tPhone))
            .thenAnswer((_) async => 60);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SendOtpEvent(phone: tPhone)),
      expect: () => [
        AuthLoading(),
        const OtpSentState(phone: tPhone, resendInSeconds: 60),
      ],
    );
  });

  group('VerifyOtpEvent', () {
    const tPhone = '+919876543210';
    const tOtp = '458921';
    const tDeviceId = 'test-device-uuid';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthenticatedState] when OTP verification succeeds',
      build: () {
        when(() => mockSecureStorage.getOrCreateDeviceId())
            .thenAnswer((_) async => tDeviceId);
        when(() => mockAuthRepository.verifyOtp(
              phone: tPhone,
              otp: tOtp,
              deviceId: tDeviceId,
              deviceModel: any(named: 'deviceModel'),
              osVersion: any(named: 'osVersion'),
              appVersion: any(named: 'appVersion'),
            )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const VerifyOtpEvent(phone: tPhone, otp: tOtp)),
      expect: () => [
        AuthLoading(),
        const AuthenticatedState(user: tUser),
      ],
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_event.dart';
import 'package:freska_rider/features/auth/presentation/blocs/auth_state.dart';
import 'package:freska_rider/features/auth/presentation/screens/phone_login_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const PhoneLoginScreen(),
      ),
    );
  }

  testWidgets('renders welcome title and phone input field', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome to Freska'), findsOneWidget);
    expect(find.text('Mobile Phone Number'), findsOneWidget);
    expect(find.text('Get Verification Code'), findsOneWidget);
  });

  testWidgets('shows loading indicator when state is AuthLoading',
      (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

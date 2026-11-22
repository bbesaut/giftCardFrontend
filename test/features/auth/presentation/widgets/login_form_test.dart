import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/features/auth/domain/entities/auth_session.dart';
import 'package:gift_card_front/features/auth/presentation/cubit/login_cubit.dart';
import 'package:gift_card_front/features/auth/presentation/cubit/login_state.dart';
import 'package:gift_card_front/features/auth/presentation/widgets/login_form.dart';
import 'package:gift_card_front/features/home/presentation/home_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

Widget _wrap(LoginCubit cubit) { // creates widget with the widget we want to test (LoginForm) and inject the cubit in param
  return MaterialApp( // general env of the app
    home: BlocProvider<LoginCubit>.value(
      value: cubit,
      child: const Scaffold(body: LoginForm()),
    ),
  );
}

void main() {
  late _MockLoginCubit cubit; // late = will be initialized later before we use it

  setUp(() { // we create the mock cubit 
    cubit = _MockLoginCubit();
    when(() => cubit.state).thenReturn(const LoginState.initial()); // when we ask for the cubit.state, then .. (we change the getter behavior)
    when(
      () => cubit.login(email: any(named: 'email'), password: any(named: 'password')), // when login fct called with any value named x
    ).thenAnswer((_) async {}); // (_) = parameter we wont use, so to resume here = do anything
  });

  testWidgets('renders an email field, a password field and a submit button', (tester) async { //syntax for widget tests
    await tester.pumpWidget(_wrap(cubit)); // Flutter prepares and shows our widget in an test env

    expect(find.byType(TextFormField), findsNWidgets(2)); // we expect to find 2 TextFormField
    expect(find.text('Log in'), findsOneWidget); // we expect to find 1 Widget who shows this text
  });

  testWidgets('shows validation errors and does not call the cubit when fields are empty', (tester) async {
    await tester.pumpWidget(_wrap(cubit));

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(() => cubit.login(email: any(named: 'email'), password: any(named: 'password')));
  });

  testWidgets('calls cubit.login with the entered credentials when the form is valid', (tester) async {
    await tester.pumpWidget(_wrap(cubit));

    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    verify(() => cubit.login(email: 'user@example.com', password: 'secret123')).called(1);
  });

  testWidgets('shows a loading indicator and disables the button while LoginLoading', (tester) async {
    when(() => cubit.state).thenReturn(const LoginState.loading());

    await tester.pumpWidget(_wrap(cubit));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('shows a SnackBar with the failure message on LoginFailure', (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable([const LoginState.failure('Invalid email or password')]),
      initialState: const LoginState.initial(),
    );

    await tester.pumpWidget(_wrap(cubit));
    await tester.pump();

    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('navigates to HomePage on LoginSuccess', (tester) async {
    whenListen(
      cubit,
      Stream.fromIterable([const LoginState.success(AuthSession(accessToken: 'jwt.token.value'))]),
      initialState: const LoginState.initial(),
    );

    await tester.pumpWidget(_wrap(cubit));
    // The page transition is animated: let it fully settle before asserting.
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_card_front/core/network/auth_session_store.dart';
import 'package:gift_card_front/core/network/dio_client.dart';
import 'package:gift_card_front/features/auth/data/datasources/auth_api_client.dart';
import 'package:gift_card_front/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:gift_card_front/features/auth/presentation/cubit/login_cubit.dart';
import 'package:gift_card_front/features/auth/presentation/widgets/login_form.dart';
import 'package:gift_card_front/features/home/presentation/home_page.dart';
import 'package:mocktail/mocktail.dart';

// Only the HTTP transport is faked here. Everything above it - DTOs,
// AuthApiClient, AuthRepositoryImpl, AuthSessionStore, LoginCubit, the
// widgets - is the real production code, wired together exactly like
// service_locator.dart does it. This is what proves the assembly works,
// not just each piece in isolation.
class _MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late _MockHttpClientAdapter adapter;
  late AuthSessionStore sessionStore;
  late LoginCubit cubit;

  setUpAll(() {
    // code executed one time before all tests in this file
    registerFallbackValue(
      RequestOptions(path: ''),
    ); // with mocktail certain args need a remplacement value
  });

  setUp(() {
    // executed before each test
    adapter = _MockHttpClientAdapter(); // create a fake adapter, he won't send real http requests to serv, we are gonna change the responses
    final dio = createDioClient()..httpClientAdapter = adapter; // we create the dio with the mock adapter // .. = dio.httpClientAdapter... (to avoid writing a new line)
    sessionStore = AuthSessionStore();
    final apiClient = AuthApiClient(
      dio,
    ); // create the apiclient (handles the http communication with backend)
    final repository = AuthRepositoryImpl(apiClient, sessionStore);
    cubit = LoginCubit(
      repository,
    ); // we finally create the cubit we are going to test
  });

  tearDown(() {
    // executed after each test
    cubit.close(); // release resources, avoid memory leaks, ..
  });

  ResponseBody jsonResponse(Map<String, dynamic> body, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  Widget wrap() {
    return MaterialApp(
      home: BlocProvider<LoginCubit>.value(
        value: cubit,
        child: const Scaffold(body: LoginForm()),
      ),
    );
  }

  testWidgets('logs in through the real stack and reaches HomePage', (
    tester,
  ) async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({'accessToken': 'jwt.token.value'}, 200),
    );

    await tester.pumpWidget(
      wrap(),
    ); // prepares a real application with the right Widget, cubit etc
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    ); // types the text into the first field
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle(); // in test mode, i have to
    // pump = verify if ui reconstruction needed, and does it (only 1 frame)
    // pumpAndSettle = pump and stop only when ui is stabilized

    expect(find.byType(HomePage), findsOneWidget);
    expect(sessionStore.accessToken, 'jwt.token.value');
  });

  testWidgets('shows the backend error message on invalid credentials', (
    tester,
  ) async {
    when(() => adapter.fetch(any(), any(), any())).thenAnswer(
      (_) async => jsonResponse({
        'error': 'Unauthorized',
        'message': 'Invalid email or password',
      }, 401),
    );

    await tester.pumpWidget(wrap());
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password'), findsOneWidget);
    expect(sessionStore.isAuthenticated, isFalse);
  });
}

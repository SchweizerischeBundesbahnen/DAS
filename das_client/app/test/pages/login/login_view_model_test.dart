import 'dart:async';

import 'package:app/di/scope_handler.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:auth/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../test_util.dart';
import 'login_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Authenticator>(), MockSpec<OidcToken>(), MockSpec<ScopeHandler>()])
void main() {
  late LoginViewModel testee;
  late MockAuthenticator mockAuthenticator;
  late MockScopeHandler mockScopeHandler;
  late StreamSubscription<LoginModel> subscription;
  final List<LoginModel> emitRegister = [];

  setUp(() async {
    mockAuthenticator = MockAuthenticator();
    mockScopeHandler = MockScopeHandler();
    GetIt.I.registerSingleton<Authenticator>(mockAuthenticator);
    GetIt.I.registerSingleton<ScopeHandler>(mockScopeHandler);
    when(mockScopeHandler.isInStack()).thenReturn(false);
    when(mockScopeHandler.isTop()).thenReturn(false);

    testee = LoginViewModel();
    subscription = testee.model.listen(emitRegister.add);
    await processStreams();
  });

  tearDown(() {
    reset(mockAuthenticator);
    GetIt.I.reset();
    subscription.cancel();
    emitRegister.clear();
    testee.dispose();
  });

  test('model_whenInitialized_thenIsInitialModel', () {
    expect(emitRegister, hasLength(1));
    expect(emitRegister.first, equals(LoggedOut()));
  });

  test('login_whenAuthenticationSuccessful_thenEmitsLoadingAndLoggedIn', () async {
    // ARRANGE
    when(mockAuthenticator.login(tokenId: anyNamed('tokenId'))).thenAnswer((_) => Future.value(MockOidcToken()));

    // ACT
    await testee.login();
    await processStreams();

    // EXPECT
    expect(emitRegister, hasLength(3));
    expect(
      emitRegister,
      orderedEquals([LoggedOut(), Loading(), LoggedIn()]),
    );
  });

  test('login_whenAuthenticationThrows_thenEmitsLoadingAndError', () async {
    // ARRANGE
    final argumentError = ArgumentError();
    when(mockAuthenticator.login(tokenId: anyNamed('tokenId'))).thenThrow(argumentError);

    // ACT
    await testee.login();
    await processStreams();

    // EXPECT
    expect(emitRegister, hasLength(3));
    expect(
      emitRegister,
      orderedEquals([LoggedOut(), Loading(), Error(errorMessage: argumentError.toString())]),
    );
  });

  test('setConnectToTmsVad_whenIsFalseAndUpdatedWithFalse_thenDoesNothing', () async {
    // ACT
    testee.setConnectToTmsVad(false);
    await processStreams();

    // EXPECT
    expect(emitRegister, hasLength(1));
    expect(emitRegister.first, equals(LoggedOut()));
  });

  test('setConnectToTmsVad_whenIsFalseAndUpdatedWithTrue_thenEmitsWithTrue', () async {
    // ACT
    testee.setConnectToTmsVad(true);
    await processStreams();

    // EXPECT
    expect(emitRegister, hasLength(2));
    expect(emitRegister, orderedEquals([LoggedOut(), LoggedOut(connectToTmsVad: true)]));
  });
}

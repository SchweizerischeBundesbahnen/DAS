import 'dart:async';

import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:auth/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../test_util.dart';
import 'login_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Authenticator>(), MockSpec<OidcToken>()])
void main() {
  late LoginViewModel testee;
  late MockAuthenticator mockAuthenticator;
  late StreamSubscription<LoginModel> subscription;
  final List<LoginModel> emitRegister = [];

  setUp(() async {
    mockAuthenticator = MockAuthenticator();
    testee = LoginViewModel(authenticator: mockAuthenticator);
    subscription = testee.model.listen(emitRegister.add);
    await processStreams();
  });

  tearDown(() {
    reset(mockAuthenticator);
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

  test('setConnectToTmsVad_whenIsFalseAndUpdatedWithFalse_thenDoesNothing', () {
    // ACT
    testee.setConnectToTmsVad(false);

    // EXPECT
    expect(emitRegister, hasLength(1));
    expect(emitRegister.first, equals(LoggedOut()));
  });

  test('setConnectToTmsVad_whenIsFalseAndUpdatedWithTrue_thenEmitsWithTrue', () {
    // ACT
    testee.setConnectToTmsVad(true);

    // EXPECT
    expect(emitRegister, hasLength(2));
    expect(emitRegister, orderedEquals([LoggedOut(), LoggedOut(connectToTmsVad: true)]));
  });
}

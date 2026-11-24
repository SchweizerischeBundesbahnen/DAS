import 'dart:async';

import 'package:app/di/scope_handler.dart';
import 'package:app/flavor.dart';
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

    testee = LoginViewModel(flavor: Flavor.dev());
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
    expect(emitRegister.first, equals(LoggedOut(connectToTmsVad: true)));
  });

  test('login_whenAuthenticationSuccessful_thenEmitsLoadingAndLoggedIn', () async {
    // GIVEN
    when(mockAuthenticator.login(tokenId: anyNamed('tokenId'))).thenAnswer((_) => Future.value(MockOidcToken()));

    // WHEN
    await testee.login();
    await processStreams();

    // THEN
    expect(emitRegister, hasLength(3));
    expect(
      emitRegister,
      orderedEquals([
        LoggedOut(connectToTmsVad: true),
        Loading(connectToTmsVad: true),
        LoggedIn(connectToTmsVad: true),
      ]),
    );
  });

  test('login_whenAuthenticationThrows_thenEmitsLoadingAndError', () async {
    // GIVEN
    final argumentError = ArgumentError();
    when(mockAuthenticator.login(tokenId: anyNamed('tokenId'))).thenThrow(argumentError);

    // WHEN
    await testee.login();
    await processStreams();

    // THEN
    expect(emitRegister, hasLength(3));
    expect(
      emitRegister,
      orderedEquals([
        LoggedOut(connectToTmsVad: true),
        Loading(connectToTmsVad: true),
        Error(errorMessage: argumentError.toString(), connectToTmsVad: true),
      ]),
    );
  });

  test('setConnectToTmsVad_whenIsTrueAndUpdatedWithTrue_thenDoesNothing', () async {
    // WHEN
    testee.setConnectToTmsVad(true);
    await processStreams();

    // THEN
    expect(emitRegister, hasLength(1));
    expect(emitRegister.first, equals(LoggedOut(connectToTmsVad: true)));
  });

  test('setConnectToTmsVad_whenIsTrueAndUpdatedWithFalse_thenEmitsWithFalse', () async {
    // WHEN
    testee.setConnectToTmsVad(false);
    await processStreams();

    // THEN
    expect(emitRegister, hasLength(2));
    expect(emitRegister, orderedEquals([LoggedOut(connectToTmsVad: true), LoggedOut(connectToTmsVad: false)]));
  });
}

import 'dart:convert';

import 'package:auth/src/authenticator_config.dart';
import 'package:auth/src/azure_authenticator.dart';
import 'package:auth/src/oidc_client_provider.dart';
import 'package:auth/src/token_spec.dart';
import 'package:auth/src/token_spec_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

import 'azure_authenticator_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<OidcClientFactory>(),
  MockSpec<OidcClient>(),
  MockSpec<OidcToken>(),
  MockSpec<FlutterSecureStorage>(),
])
void main() {
  late MockOidcClientFactory mockOidcClientFactory;
  late MockOidcClient mockOidcClient;
  late MockFlutterSecureStorage mockFlutterSecureStorage;
  late AzureAuthenticator authenticator;

  const trustedTenants = <String, String>{
    'SBB': sbbTenantId,
    'SOB': sobTenantId,
    'BLS': blsTenantId,
  };

  final tokenSpec = const TokenSpec(
    id: TokenSpec.defaultTokenId,
    displayName: 'Test Token',
    scopes: ['scope1'],
  );

  final config = AuthenticatorConfig(
    discoveryUrl: 'https://discovery.url',
    clientId: 'client-id',
    redirectUrl: 'https://redirect.url',
    tokenSpecs: TokenSpecProvider([tokenSpec]),
    trustedTenantIds: trustedTenants.values.toList(),
  );

  setUp(() {
    mockOidcClientFactory = MockOidcClientFactory();
    mockOidcClient = MockOidcClient();
    mockFlutterSecureStorage = MockFlutterSecureStorage();

    when(
      mockOidcClientFactory.createClient(
        discoveryUrl: anyNamed('discoveryUrl'),
        clientId: anyNamed('clientId'),
        redirectUrl: anyNamed('redirectUrl'),
        postLogoutRedirectUrl: anyNamed('postLogoutRedirectUrl'),
      ),
    ).thenAnswer((_) async => mockOidcClient);

    authenticator = AzureAuthenticator(
      config: config,
      oidcClientFactory: mockOidcClientFactory,
      storage: mockFlutterSecureStorage,
    );
  });

  for (final tenantId in trustedTenants.entries) {
    test('login_whenWith${tenantId.key}TenantId_thenShouldReturnToken', () async {
      // GIVEN
      final idToken = _createIdToken(tenantId.value);
      final mockToken = MockOidcToken();
      when(mockToken.idToken).thenReturn(idToken);
      when(
        mockOidcClient.login(
          scopes: anyNamed('scopes'),
          prompt: anyNamed('prompt'),
        ),
      ).thenAnswer((_) async => mockToken);

      // WHEN / THEN
      final result = await authenticator.login();
      expect(result, mockToken);
    });

    test('token_whenWith${tenantId.key}TenantId_thenShouldReturnToken', () async {
      // GIVEN
      final idToken = _createIdToken(tenantId.value);
      final mockToken = MockOidcToken();
      when(mockToken.idToken).thenReturn(idToken);
      when(
        mockOidcClient.getToken(
          scopes: anyNamed('scopes'),
          forceRefresh: anyNamed('forceRefresh'),
        ),
      ).thenAnswer((_) async => mockToken);

      // WHEN / THEN
      final result = await authenticator.token();
      expect(result, mockToken);
    });

    test('isAuthenticated_whenWith${tenantId.key}TenantId_thenShouldReturnTrue', () async {
      // GIVEN
      final idToken = _createIdToken(tenantId.value);
      final mockToken = MockOidcToken();
      when(mockToken.idToken).thenReturn(idToken);
      when(
        mockOidcClient.getToken(
          scopes: anyNamed('scopes'),
          forceRefresh: anyNamed('forceRefresh'),
        ),
      ).thenAnswer((_) async => mockToken);

      // WHEN / THEN
      final result = await authenticator.isAuthenticated;
      expect(result, isTrue);
    });
  }

  test('login_whenWithUnknownTenantId_thenShouldThrowException', () async {
    // GIVEN
    const untrustedTenantId = 'untrusted-tenant-id';
    final idToken = _createIdToken(untrustedTenantId);
    final mockToken = MockOidcToken();
    when(mockToken.idToken).thenReturn(idToken);
    when(
      mockOidcClient.login(
        scopes: anyNamed('scopes'),
        prompt: anyNamed('prompt'),
      ),
    ).thenAnswer((_) async => mockToken);

    // WHEN / THEN
    expect(() => authenticator.login(), throwsException);
  });

  test('token_whenWithUnknownTenantId_thenShouldThrowException', () async {
    // GIVEN
    const untrustedTenantId = 'untrusted-tenant-id';
    final idToken = _createIdToken(untrustedTenantId);
    final mockToken = MockOidcToken();
    when(mockToken.idToken).thenReturn(idToken);
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => mockToken);

    // WHEN / THEN
    expect(() => authenticator.token(), throwsException);
  });

  test('login_whenWithUnknownTenantId_thenShouldReturnFalse', () async {
    // GIVEN
    final idToken = _createIdToken('untrusted-tenant-id');
    final mockToken = MockOidcToken();
    when(mockToken.idToken).thenReturn(idToken);
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => mockToken);
    when(mockOidcClient.logout()).thenAnswer((_) async {});

    // WHEN / THEN
    final result = await authenticator.isAuthenticated;
    expect(result, isFalse);
    verify(mockOidcClient.logout()).called(1);
  });

  test('login_whenLoginSuccessful_thenShouldSaveToken', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final mockToken = MockOidcToken();
    when(mockToken.idToken).thenReturn(idToken);
    when(
      mockOidcClient.login(
        scopes: anyNamed('scopes'),
        prompt: anyNamed('prompt'),
      ),
    ).thenAnswer((_) async => mockToken);

    // WHEN / THEN
    final result = await authenticator.login();
    expect(result, mockToken);
    verify(mockFlutterSecureStorage.write(key: TokenSpec.defaultTokenId, value: anyNamed('value'))).called(1);
  });

  test('token_whenTokenSuccessful_thenShouldSaveToken', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final mockToken = MockOidcToken();
    when(mockToken.idToken).thenReturn(idToken);
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => mockToken);

    // WHEN / THEN
    final result = await authenticator.token();
    expect(result, mockToken);
    verify(mockFlutterSecureStorage.write(key: TokenSpec.defaultTokenId, value: anyNamed('value'))).called(1);
  });

  test('login_whenLoginFailed_thenShouldReadOfflineToken', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().add(const Duration(hours: 1)),
    );
    when(
      mockOidcClient.login(
        scopes: anyNamed('scopes'),
        prompt: anyNamed('prompt'),
      ),
    ).thenThrow(NetworkException());
    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    final result = await authenticator.login();
    expect(result, mockToken);
    verify(mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId)).called(1);
  });

  test('token_whenLoginFailed_thenShouldReturnExpiredOfflineToken', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().subtract(const Duration(hours: 1)),
    );
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenThrow(NetworkException());

    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    final result = await authenticator.token();
    expect(result, mockToken);
    verify(mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId)).called(1);
  });

  test('token_whenLoginFailed_thenShouldNotReturnOfflineTokenOlderThen24Hours', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().subtract(const Duration(hours: 25)),
    );
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenThrow(NetworkException());

    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    expect(authenticator.token(), throwsException);
    await Future.delayed(Duration.zero); // wait for async token loading
    verify(mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId)).called(1);
  });

  test('reauthenticationRequired_whenLoginFailedWithNonNetworkException_emitTrue', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final emittedValues = <bool>[];
    authenticator.reauthenticationRequired.listen(emittedValues.add);

    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().subtract(const Duration(hours: 1)),
    );
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenThrow(Exception());

    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    final result = await authenticator.token();
    expect(result, mockToken);
    expect(emittedValues, hasLength(2));
    expect(emittedValues[0], isFalse);
    expect(emittedValues[1], isTrue);
  });

  test('reauthenticationRequired_whenLoginFailedWithNetworkException_emitFalse', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final emittedValues = <bool>[];
    authenticator.reauthenticationRequired.listen(emittedValues.add);

    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().subtract(const Duration(hours: 1)),
    );
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenThrow(NetworkException());

    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    final result = await authenticator.token();
    expect(result, mockToken);
    expect(emittedValues, hasLength(1));
    expect(emittedValues[0], isFalse);
  });

  test('reauthenticationRequired_whenLoginFailedWithConnectionError_emitFalse', () async {
    // GIVEN
    final idToken = _createIdToken(sbbTenantId);
    final emittedValues = <bool>[];
    authenticator.reauthenticationRequired.listen(emittedValues.add);

    final mockToken = OidcToken(
      tokenType: 'Bearer',
      accessToken: '',
      idToken: idToken,
      accessTokenExpirationDateTime: DateTime.now().subtract(const Duration(hours: 1)),
    );
    when(
      mockOidcClient.getToken(
        scopes: anyNamed('scopes'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenThrow(Exception('Connection error'));

    when(
      mockFlutterSecureStorage.read(key: TokenSpec.defaultTokenId),
    ).thenAnswer((_) async => mockToken.toJsonString());

    // WHEN / THEN
    final result = await authenticator.token();
    expect(result, mockToken);
    expect(emittedValues, hasLength(1));
    expect(emittedValues[0], isFalse);
  });
}

String _createIdToken(String tenantId) {
  String removePadding(String base64) => base64.replaceAll('=', '');

  final header = removePadding(base64Url.encode(utf8.encode(json.encode({'typ': 'JWT', 'alg': 'HS256'}))));
  final payload = removePadding(base64Url.encode(utf8.encode(json.encode({'tid': tenantId}))));
  final signature = removePadding(base64Url.encode(utf8.encode('signature')));
  return '$header.$payload.$signature';
}

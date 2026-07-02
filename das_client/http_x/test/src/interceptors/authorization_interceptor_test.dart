import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_x/component.dart';
import 'package:http_x/src/interceptors/authorization_interceptor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'authorization_interceptor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthProvider>(),
  MockSpec<http.BaseRequest>(),
])
void main() {
  late AuthorizationInterceptor testee;
  late MockAuthProvider mockAuthProvider;
  late MockBaseRequest mockRequest;

  setUp(() {
    mockRequest = MockBaseRequest();
    mockAuthProvider = MockAuthProvider();
    testee = AuthorizationInterceptor(mockAuthProvider);
  });

  test('interceptRequest_whenCalled_thenShouldAddAuthorizationHeader', () async {
    // GIVEN
    final headers = <String, String>{};
    when(mockRequest.headers).thenReturn(headers);

    final token = 'token-1';
    when(mockAuthProvider.call()).thenAnswer((_) async => token);

    // WHEN
    final result = await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(result, mockRequest);
    expect(headers.containsKey('authorization'), isTrue);
    expect(headers['authorization'], token);
  });

  test('interceptRequest_whenAuthProviderThrows_thenShouldReturnRequest', () async {
    // GIVEN
    final headers = <String, String>{};
    when(mockRequest.headers).thenReturn(headers);
    when(mockAuthProvider.call()).thenThrow(Exception('Failed'));

    // WHEN
    final result = await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(result, mockRequest);
    expect(headers.containsKey('authorization'), isFalse);
  });
}

class MockBaseResponse extends Mock implements http.BaseResponse {}

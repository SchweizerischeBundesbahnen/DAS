import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_x/src/interceptors/accept_language_interceptor.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'accept_language_interceptor_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.BaseRequest>(),
])
void main() {
  late AcceptLanguageInterceptor testee;
  late MockBaseRequest mockRequest;

  setUp(() {
    testee = const AcceptLanguageInterceptor();
    mockRequest = MockBaseRequest();
  });

  test('interceptRequest_whenCalled_thenShouldAddAcceptLanguageHeader', () async {
    // GIVEN
    final headers = <String, String>{};
    when(mockRequest.headers).thenReturn(headers);

    // WHEN
    final result = await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(result, mockRequest);
    expect(headers.containsKey('Accept-Language'), isTrue);
    expect(headers['Accept-Language'], Platform.localeName);
  });
}

class MockBaseResponse extends Mock implements http.BaseResponse {}

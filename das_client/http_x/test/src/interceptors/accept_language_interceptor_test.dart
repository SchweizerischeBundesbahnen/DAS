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
  late MockBaseRequest mockRequest;
  late Map<String, String> headers;

  setUp(() {
    mockRequest = MockBaseRequest();
    headers = <String, String>{};
    when(mockRequest.headers).thenReturn(headers);
  });

  test('interceptRequest_whenLocaleHasRegion_thenShouldAddBcp47Tag', () async {
    // GIVEN
    final testee = AcceptLanguageInterceptor(localeName: () => 'de_CH');

    // WHEN
    final result = await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(result, mockRequest);
    expect(headers['Accept-Language'], 'de-CH');
  });

  test('interceptRequest_whenLocaleHasCodeset_thenShouldStripCodeset', () async {
    // GIVEN
    final testee = AcceptLanguageInterceptor(localeName: () => 'de_CH.UTF-8');

    // WHEN
    await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(headers['Accept-Language'], 'de-CH');
  });

  test('interceptRequest_whenLocaleHasModifier_thenShouldStripModifier', () async {
    // GIVEN
    final testee = AcceptLanguageInterceptor(localeName: () => 'sr_RS@latin');

    // WHEN
    await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(headers['Accept-Language'], 'sr-RS');
  });

  test('interceptRequest_whenLocaleHasVariant_thenShouldAddBcp47Tag', () async {
    // GIVEN
    final testee = AcceptLanguageInterceptor(localeName: () => 'en_US_POSIX');

    // WHEN
    await testee.interceptRequest(request: mockRequest);

    // THEN
    expect(headers['Accept-Language'], 'en-US-POSIX');
  });

  test('interceptRequest_whenLocaleIsPosixDefault_thenShouldNotAddHeader', () async {
    for (final localeName in ['C', 'POSIX', 'C.UTF-8', '']) {
      // GIVEN
      headers.clear();
      final testee = AcceptLanguageInterceptor(localeName: () => localeName);

      // WHEN
      await testee.interceptRequest(request: mockRequest);

      // THEN
      expect(headers.containsKey('Accept-Language'), isFalse, reason: localeName);
    }
  });
}

class MockBaseResponse extends Mock implements http.BaseResponse;

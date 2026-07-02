import 'dart:async';
import 'dart:io';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:logging/logging.dart';

final _log = Logger('AcceptLanguageInterceptor');

class AcceptLanguageInterceptor implements HttpInterceptor {
  const AcceptLanguageInterceptor();

  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) async => true;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final deviceLocale = Platform.localeName;
      request.headers['Accept-Language'] = deviceLocale;
    } catch (e, s) {
      _log.severe('Set accept-language header failed', e, s);
    }
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) async => false;

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) async => response;
}

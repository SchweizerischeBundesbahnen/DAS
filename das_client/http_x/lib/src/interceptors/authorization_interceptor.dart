import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('AuthorizationInterceptor');

class AuthorizationInterceptor implements HttpInterceptor {
  const AuthorizationInterceptor(this.authProvider);

  final AuthProvider? authProvider;

  @override
  FutureOr<bool> shouldInterceptRequest({required BaseRequest request}) async => authProvider != null;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final value = await authProvider!();
      request.headers['authorization'] = value;
    } catch (e, s) {
      _log.severe('Set authorization header failed', e, s);
    }
    return request;
  }

  @override
  FutureOr<bool> shouldInterceptResponse({required BaseResponse response}) async => false;

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) {
    return Future.value(response);
  }
}

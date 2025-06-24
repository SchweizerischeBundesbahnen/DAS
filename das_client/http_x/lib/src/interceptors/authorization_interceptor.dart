import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';
import 'package:logging/logging.dart';

final _log = Logger('AuthorizationInterceptor');

class AuthorizationInterceptor implements InterceptorContract {
  const AuthorizationInterceptor(this.authProvider);

  final AuthProvider? authProvider;

  @override
  Future<bool> shouldInterceptRequest() async => authProvider != null;

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
  Future<bool> shouldInterceptResponse() async => false;

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) {
    return Future.value(response);
  }
}

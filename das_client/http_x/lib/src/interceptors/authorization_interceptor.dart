import 'package:fimber/fimber.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';

class AuthorizationInterceptor implements InterceptorContract {
  const AuthorizationInterceptor(this.authorizationProvider);

  final AuthProvider? authorizationProvider;

  @override
  Future<bool> shouldInterceptRequest() async => authorizationProvider != null;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final value = await authorizationProvider!();
      request.headers['authorization'] = value;
    } catch (e, s) {
      Fimber.e('Set authorization header failed', ex: e, stacktrace: s);
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

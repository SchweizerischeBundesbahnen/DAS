import 'package:fimber/fimber.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';

class AuthorizationInterceptor implements InterceptorContract {
  const AuthorizationInterceptor(this.authorizationProvider);

  final AuthorizationProvider? authorizationProvider;

  @override
  Future<bool> shouldInterceptRequest() async => authorizationProvider != null;

  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {
      final url = request.url.toString();
      final value = await authorizationProvider!.call(url);
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

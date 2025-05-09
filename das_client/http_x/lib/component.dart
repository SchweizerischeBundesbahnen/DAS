library;

import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';
import 'package:http_x/src/interceptors/authorization_interceptor.dart';
import 'package:http_x/src/interceptors/logging_interceptor.dart';

export 'package:http/http.dart';
export 'package:http_x/src/exception/client/bad_request_exception.dart';
export 'package:http_x/src/exception/client/forbidden_exception.dart';
export 'package:http_x/src/exception/client/unauthorized_exception.dart';
export 'package:http_x/src/exception/http_exception.dart';
export 'package:http_x/src/exception/server/bad_gateway_exception.dart';
export 'package:http_x/src/exception/server/internal_server_error_exception.dart';
export 'package:http_x/src/exception/server/not_implemented_exception.dart';
export 'package:http_x/src/exception/server/service_unavailable_exception.dart';
export 'package:http_x/src/provider/auth_provider.dart';

class HttpXComponent {
  const HttpXComponent._();

  static Client createHttpClient({AuthProvider? authProvider}) {
    return InterceptedClient.build(
      client: Client(),
      interceptors: [
        AuthorizationInterceptor(authProvider),
        const LoggingInterceptor(obfuscateSecrets: true),
      ],
    );
  }
}

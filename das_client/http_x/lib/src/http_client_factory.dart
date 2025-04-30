import 'package:http_interceptor/http_interceptor.dart';
import 'package:http_x/component.dart';
import 'package:http_x/src/interceptors/authorization_interceptor.dart';
import 'package:http_x/src/interceptors/logging_interceptor.dart';

/// Creates a new HTTP client.
Client createHttpClient({AuthProvider? authorizationProvider}) {
  return InterceptedClient.build(
    client: Client(),
    interceptors: [
      AuthorizationInterceptor(authorizationProvider),
      const LoggingInterceptor(obfuscateSecrets: true),
    ],
  );
}

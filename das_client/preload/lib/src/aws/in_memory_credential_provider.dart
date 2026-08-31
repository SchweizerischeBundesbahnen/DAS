import 'dart:async';

import 'package:aws_common/aws_common.dart';

class InMemoryCredentialProvider({required final String _accessKey, required final String _secretKey})
    implements AWSCredentialsProvider {
  @override
  FutureOr<AWSCredentials> retrieve() => AWSCredentials(_accessKey, _secretKey);

  @override
  String get runtimeTypeName => 'InMemoryCredentialProvider';
}

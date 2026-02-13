import 'dart:async';

import 'package:aws_common/aws_common.dart';

class InMemoryCredentialProvider implements AWSCredentialsProvider {
  InMemoryCredentialProvider({required String accessKey, required String secretKey})
    : _accessKey = accessKey,
      _secretKey = secretKey;

  final String _accessKey;
  final String _secretKey;

  @override
  FutureOr<AWSCredentials> retrieve() {
    return AWSCredentials(_accessKey, _secretKey);
  }

  @override
  String get runtimeTypeName => 'InMemoryCredentialProvider';
}

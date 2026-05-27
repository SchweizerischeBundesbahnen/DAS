import 'dart:async';

import 'package:aws_common/aws_common.dart';

class InMemoryCredentialProvider implements AWSCredentialsProvider {
  InMemoryCredentialProvider({required this._accessKey, required this._secretKey});

  final String _accessKey;
  final String _secretKey;

  @override
  FutureOr<AWSCredentials> retrieve() {
    return AWSCredentials(_accessKey, _secretKey);
  }

  @override
  String get runtimeTypeName => 'InMemoryCredentialProvider';
}

import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:logging/logging.dart';
import 'package:preload/src/aws/dto/list_bucket_result_dto.dart';
import 'package:preload/src/aws/in_memory_credential_provider.dart';
import 'package:settings/component.dart';
import 'package:xml/xml.dart';

final _log = Logger('S3Client');

class S3Client {
  S3Client({required AwsConfiguration configuration})
    : _configuration = configuration,
      _signer = AWSSigV4Signer(
        credentialsProvider: InMemoryCredentialProvider(
          accessKey: configuration.accessKey,
          secretKey: configuration.accessSecret,
        ),
      ),
      _httpClient = AWSHttpClient();

  final AwsConfiguration _configuration;
  final AWSSigV4Signer _signer;
  final AWSHttpClient _httpClient;

  Future<ListBucketResultDto?> listBucket() async {
    final signedRequest = _listBucketRequest();
    final response = await signedRequest.send(client: _httpClient).response;

    if (response.statusCode == HttpStatus.ok) {
      final responseBody = await response.decodeBody();
      return _parseListBucketResult(responseBody);
    } else {
      _log.info('Failed to list bucket. Status code: ${response.statusCode}');
      return null;
    }
  }

  Future<List<int>?> getObject(String key) async {
    final signedRequest = _getRequest(key);
    final response = await signedRequest.send(client: _httpClient).response;

    if (response.statusCode == HttpStatus.ok) {
      return response.bodyBytes;
    } else {
      _log.warning('Failed to get object with key $key. Status code: ${response.statusCode}');
      return null;
    }
  }

  ListBucketResultDto _parseListBucketResult(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final rootElement = document.rootElement;
    return ListBucketResultDto(xmlElement: rootElement);
  }

  AWSSignedRequest _listBucketRequest() {
    return _getRequest('', {'list-type': '2'});
  }

  AWSSignedRequest _getRequest(String key, [Map<String, String>? queryParams]) {
    final uri = Uri.https(_configuration.bucketUrl, key, queryParams);
    final request = AWSHttpRequest.get(uri);

    return _signer.signSync(
      request,
      credentialScope: AWSCredentialScope(
        region: _configuration.region,
        service: AWSService.s3,
      ),
    );
  }
}

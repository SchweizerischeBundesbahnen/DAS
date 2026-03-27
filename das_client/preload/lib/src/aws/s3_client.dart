import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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

  Future<File?> downloadZip(String key) async {
    final signedRequest = _getRequest(key);
    AWSBaseHttpResponse response;
    try {
      response = await signedRequest.send(client: _httpClient).response;
    } catch (e, s) {
      _log.severe('HTTP error while requesting $key from S3.', e, s);
      return null;
    }

    if (response.statusCode != HttpStatus.ok) {
      _log.warning('Failed to download object with key $key. Status code: ${response.statusCode}');
      return null;
    }

    try {
      final supportDir = await getApplicationSupportDirectory();
      final preloadDir = Directory(p.join(supportDir.path, 'preload'));
      if (!await preloadDir.exists()) {
        await preloadDir.create(recursive: true);
      }

      // Use the last path segment of the key as file name
      final fileName = key.split('/').isNotEmpty ? key.split('/').last : key;
      final outFile = File(p.join(preloadDir.path, fileName));

      final sink = outFile.openWrite(mode: FileMode.writeOnly);
      try {
        await for (final chunk in response.body) {
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      _log.fine('successfully downloaded: $key');
      return outFile;
    } catch (e, s) {
      _log.severe('Failed to write zip for key $key to local storage.', e, s);
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

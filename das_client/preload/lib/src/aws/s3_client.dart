import 'dart:io';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
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
      );

  final AwsConfiguration _configuration;
  final AWSSigV4Signer _signer;

  Future<ListBucketResultDto?> listBucket() async {
    final httpClient = AWSHttpClient();
    try {
      final signedRequest = _listBucketRequest();
      final response = await signedRequest.send(client: httpClient).response;

      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.decodeBody();
        return _parseListBucketResult(responseBody);
      } else {
        _log.severe('Failed to list bucket. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _log.severe('Failed to list bucket.', e);
      return null;
    } finally {
      httpClient.close();
    }
  }

  Future<File> downloadFile(String key, {required Directory saveTo}) async {
    final httpClient = AWSHttpClient();
    try {
      final signedRequest = _getRequest(key);
      final response = await signedRequest.send(client: httpClient).response;

      if (response.statusCode != HttpStatus.ok) {
        try {
          response.body.drain();
        } catch (_) {}
        throw Exception('Failed to download object with key $key. Status code: ${response.statusCode}');
      }

      final fileName = key.split('/').isNotEmpty ? key.split('/').last : key;
      final outFile = File(p.join(saveTo.path, fileName));

      final sink = outFile.openWrite(mode: FileMode.writeOnly);
      try {
        await for (final chunk in response.body) {
          sink.add(chunk);
        }
        await sink.flush();
      } finally {
        await sink.close();
      }

      _log.fine('Successfully downloaded object with key $key');
      return outFile;
    } catch (e) {
      _log.severe('Failed to download object with key $key.', e);
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  ListBucketResultDto _parseListBucketResult(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final rootElement = document.rootElement;
    return ListBucketResultDto(xmlElement: rootElement);
  }

  AWSSignedRequest _listBucketRequest() => _getRequest('/', {'list-type': '2'});

  AWSSignedRequest _getRequest(String key, [Map<String, String>? queryParams]) {
    final uri = Uri.https(_configuration.bucketUrl, key, queryParams);
    final request = AWSHttpRequest.get(uri);

    return _signer.signSync(
      request,
      credentialScope: AWSCredentialScope(
        region: _configuration.region,
        service: AWSService.s3,
      ),
      serviceConfiguration: S3ServiceConfiguration(),
    );
  }
}

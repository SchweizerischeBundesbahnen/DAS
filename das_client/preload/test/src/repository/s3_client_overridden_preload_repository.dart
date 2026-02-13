import 'package:preload/src/aws/s3_client.dart';
import 'package:preload/src/repository/preload_repository_impl.dart';
import 'package:settings/component.dart';

class S3ClientOverriddenPreloadRepository extends PreloadRepositoryImpl {
  S3ClientOverriddenPreloadRepository({
    required super.databaseService,
    required super.sferaLocalRepo,
    required S3Client s3Client,
  }) : _s3Client = s3Client;

  final S3Client _s3Client;

  @override
  S3Client createS3Client(AwsConfiguration awsConfiguration) {
    return _s3Client;
  }
}

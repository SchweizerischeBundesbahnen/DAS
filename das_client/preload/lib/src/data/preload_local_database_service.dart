import 'package:preload/src/model/s3file.dart';

abstract class PreloadLocalDatabaseService {
  const PreloadLocalDatabaseService._();

  Future<int> saveS3File(S3File file);

  Future<List<S3File>> findAllNotDeletedFiles();
}

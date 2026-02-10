import 'package:intl/intl.dart';
import 'package:preload/src/model/s3file.dart';
import 'package:sfera/component.dart';

class PreloadDetails {
  PreloadDetails({
    required this.files,
    required this.status,
    required this.metrics,
  });

  final List<S3File> files;
  final PreloadStatus status;
  final DbMetrics metrics;

  int get totalFilesCount => files.length;

  int get totalSize => files.fold(0, (sum, file) => sum + file.size);

  int get initialFilesCount => files.where((f) => f.status == S3FileSyncStatus.initial).length;

  int get initialSize =>
      files.where((f) => f.status == S3FileSyncStatus.initial).fold(0, (sum, file) => sum + file.size);

  int get errorFilesCount =>
      files.where((f) => f.status == S3FileSyncStatus.error || f.status == S3FileSyncStatus.corrupted).length;

  int get errorSize => files
      .where((f) => f.status == S3FileSyncStatus.error || f.status == S3FileSyncStatus.corrupted)
      .fold(0, (sum, file) => sum + file.size);

  int get downloadedFilesCount => files.where((f) => f.status == S3FileSyncStatus.downloaded).length;

  int get downloadedSize =>
      files.where((f) => f.status == S3FileSyncStatus.downloaded).fold(0, (sum, file) => sum + file.size);

  DateTime? get lastUpdated {
    final format = DateFormat('yyyy-MM-dd\'T\'HH-mm-ss\'Z\'');
    return files
        .where((f) => f.status == S3FileSyncStatus.downloaded)
        .map((f) => format.tryParse(f.name.split('.').first))
        .fold<DateTime?>(null, (latest, fileDate) {
          if (fileDate != null) {
            return latest == null || fileDate.isAfter(latest) ? fileDate : latest;
          } else {
            return latest;
          }
        });
  }
}

enum PreloadStatus { idle, running, missingConfiguration }

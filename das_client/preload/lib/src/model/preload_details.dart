import 'package:intl/intl.dart';
import 'package:preload/src/model/s3_file.dart';
import 'package:sfera/component.dart';

class PreloadDetails {
  static const dateFormatUtcPattern = 'yyyy-MM-dd\'T\'HH-mm-ss\'Z\'';

  PreloadDetails({
    required this.files,
    required this.status,
    required this.metrics,
  });

  final List<S3File> files;
  final PreloadStatus status;
  final SferaDbMetrics metrics;

  int get totalFilesCount => files.length;

  int get totalSize => files.fold(0, (sum, file) => sum + file.size);

  int get initialFilesCount => files.whereStatus(.initial).length;

  int get initialSize => files.whereStatus(.initial).fold(0, (sum, file) => sum + file.size);

  int get errorFilesCount => _errorFiles.length;

  int get errorSize => _errorFiles.fold(0, (sum, file) => sum + file.size);

  int get downloadedFilesCount => files.whereStatus(.downloaded).length;

  int get downloadedSize => files.whereStatus(.downloaded).fold(0, (sum, file) => sum + file.size);

  DateTime? get lastUpdated {
    final format = DateFormat(dateFormatUtcPattern);
    return files.whereStatus(.downloaded).map((f) => format.tryParse(f.name.split('.').first, true)).fold<DateTime?>(
      null,
      (latest, fileDate) {
        if (fileDate != null) {
          return latest == null || fileDate.isAfter(latest) ? fileDate : latest;
        } else {
          return latest;
        }
      },
    );
  }

  Iterable<S3File> get _errorFiles => files.where((f) => f.status == .error || f.status == .corrupted);

  @override
  String toString() {
    return 'PreloadDetails{status: $status}';
  }
}

enum PreloadStatus { idle, running, missingConfiguration }

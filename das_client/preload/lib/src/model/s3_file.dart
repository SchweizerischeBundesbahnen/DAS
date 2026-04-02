class S3File {
  S3File({
    required this.name,
    required this.eTag,
    required this.size,
    required this.status,
  });

  final String name;
  final String eTag;
  final int size;
  final S3FileSyncStatus status;

  S3File copyWith({
    String? name,
    String? eTag,
    int? size,
    S3FileSyncStatus? status,
  }) {
    return S3File(
      name: name ?? this.name,
      eTag: eTag ?? this.eTag,
      size: size ?? this.size,
      status: status ?? this.status,
    );
  }
}

enum S3FileSyncStatus {
  initial,
  downloaded,
  error,
  corrupted,
}

extension S3FileIterableExtension on Iterable<S3File> {
  Iterable<S3File> whereStatus(S3FileSyncStatus status) => where((file) => file.status == status);
}

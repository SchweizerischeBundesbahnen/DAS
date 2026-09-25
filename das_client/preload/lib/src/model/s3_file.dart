class const S3File({
  required final String name,
  required final String eTag,
  required final int size,
  required final S3FileSyncStatus status,
}) {
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

  @override
  String toString() {
    return 'S3File(name: $name, eTag: $eTag, size: $size, status: $status)';
  }

  @override
  int get hashCode => Object.hash(name, eTag, size, status);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! S3File) return false;
    return name == other.name && eTag == other.eTag && size == other.size && status == other.status;
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

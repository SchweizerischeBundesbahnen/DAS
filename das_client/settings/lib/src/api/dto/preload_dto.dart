import 'package:json_annotation/json_annotation.dart';

part 'preload_dto.g.dart';

@JsonSerializable()
class PreloadDto({
  required final String bucketUrl,
  required final String accessKey,
  required final String accessSecret,
  required final String region,
}) {
  factory fromJson(Map<String, dynamic> json) {
    return _$PreloadDtoFromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreloadDto &&
          runtimeType == other.runtimeType &&
          bucketUrl == other.bucketUrl &&
          accessKey == other.accessKey &&
          accessSecret == other.accessSecret &&
          region == other.region;

  @override
  int get hashCode => Object.hash(bucketUrl, accessKey, accessSecret, region);
}

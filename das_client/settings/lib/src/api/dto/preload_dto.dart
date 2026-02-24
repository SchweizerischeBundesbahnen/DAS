import 'package:json_annotation/json_annotation.dart';

part 'preload_dto.g.dart';

@JsonSerializable()
class PreloadDto {
  PreloadDto({required this.bucketUrl, required this.accessKey, required this.accessSecret});

  factory PreloadDto.fromJson(Map<String, dynamic> json) {
    return _$PreloadDtoFromJson(json);
  }

  final String bucketUrl;
  final String accessKey;
  final String accessSecret;

  Map<String, dynamic> toJson() => _$PreloadDtoToJson(this);
}

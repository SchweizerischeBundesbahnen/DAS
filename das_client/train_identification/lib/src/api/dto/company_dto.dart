import 'package:json_annotation/json_annotation.dart';

part 'company_dto.g.dart';

@JsonSerializable()
class CompanyDto {
  CompanyDto({
    required this.code,
    required this.shortName,
  });

  factory CompanyDto.fromJson(Map<String, dynamic> json) => _$CompanyDtoFromJson(json);

  final String code;
  final String shortName;

  Map<String, dynamic> toJson() => _$CompanyDtoToJson(this);
}

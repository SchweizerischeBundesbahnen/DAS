import 'package:core_data/component.dart';
import 'package:json_annotation/json_annotation.dart';

part 'company_dto.g.dart';

@JsonSerializable()
class CompanyDto({
  required final String code,
  required final String shortName,
}) {
  factory fromJson(Map<String, dynamic> json) => _$CompanyDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyDtoToJson(this);
}

extension CompanyDtoX on CompanyDto {
  Company toDomain() => Company(code: code, shortName: shortName);
}

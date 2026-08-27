import 'package:core_data/component.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';

part 'company_match_dto.g.dart';

@JsonSerializable()
class CompanyMatchDto({
  required final CompanyDto company,
  required final DateTime startDate,
}) {
  factory CompanyMatchDto.fromJson(Map<String, dynamic> json) => _$CompanyMatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyMatchDtoToJson(this);
}

extension CompanyMatchDtoX on CompanyMatchDto {
  CompanyMatch toCompanyMatch() => CompanyMatch(companyCode: company.code, startDate: startDate);
}

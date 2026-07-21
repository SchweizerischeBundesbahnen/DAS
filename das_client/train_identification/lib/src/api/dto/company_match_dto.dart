import 'package:json_annotation/json_annotation.dart';
import 'package:train_identification/src/api/dto/company_dto.dart';
import 'package:train_identification/src/model/company_match.dart';

part 'company_match_dto.g.dart';

@JsonSerializable()
class CompanyMatchDto {
  CompanyMatchDto({
    required this.company,
    required this.startDate,
  });

  factory CompanyMatchDto.fromJson(Map<String, dynamic> json) => _$CompanyMatchDtoFromJson(json);

  final CompanyDto company;
  final DateTime startDate;

  Map<String, dynamic> toJson() => _$CompanyMatchDtoToJson(this);
}

extension CompanyMatchDtoX on CompanyMatchDto {
  CompanyMatch toCompanyMatch() => CompanyMatch(company: company.toCompany(), startDate: startDate);
}

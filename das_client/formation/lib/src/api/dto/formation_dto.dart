import 'package:collection/collection.dart';
import 'package:formation/src/model/formation.dart';
import 'package:formation/src/model/formation_run.dart';
import 'package:json_annotation/json_annotation.dart';

part 'formation_dto.g.dart';

@JsonSerializable()
class FormationDto {
  FormationDto({
    required this.operationalTrainNumber,
    required this.company,
    required this.operationalDay,
    required this.formationRuns,
  });

  factory FormationDto.fromJson(Map<String, dynamic> json) {
    return _$FormationDtoFromJson(json);
  }

  final String operationalTrainNumber;
  final String company;
  final DateTime operationalDay;
  final List<dynamic> formationRuns;

  Map<String, dynamic> toJson() => _$FormationDtoToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormationDto &&
          runtimeType == other.runtimeType &&
          operationalTrainNumber == other.operationalTrainNumber &&
          company == other.company &&
          operationalDay == other.operationalDay &&
          ListEquality().equals(formationRuns, formationRuns);

  @override
  int get hashCode => Object.hash(operationalTrainNumber, company, operationalDay, formationRuns);

  @override
  String toString() {
    return 'FormationDto{operationalTrainNumber: $operationalTrainNumber, company: $company, operationalDay: $operationalDay, formationRuns: $formationRuns}';
  }
}

extension FormationDtoX on FormationDto {
  Formation toDomain() {
    return Formation(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
      formationRuns: formationRuns.map((e) => FormationRun.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

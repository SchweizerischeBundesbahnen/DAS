// coverage:ignore-file

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/data/local/formation_database_service_impl.dart';
import 'package:formation/src/model/formation.dart';
import 'package:formation/src/model/formation_run.dart';

class FormationTable extends Table {
  TextColumn get operationalTrainNumber => text()();

  TextColumn get company => text()();

  DateTimeColumn get operationalDay => dateTime()();

  TextColumn get formationRuns => text()();

  TextColumn get etag => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {operationalTrainNumber, company, operationalDay};
}

extension FormationMapperX on FormationDto {
  FormationTableCompanion toCompanion(String? etag) {
    return FormationTableCompanion.insert(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
      formationRuns: jsonEncode(formationRuns),
      etag: etag != null ? Value(etag) : const Value.absent(),
    );
  }
}

extension FormationTableDataX on FormationTableData {
  Formation toDomain() {
    return Formation(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
      formationRuns: ((jsonDecode(formationRuns)) as List<dynamic>)
          .map((e) => FormationRun.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

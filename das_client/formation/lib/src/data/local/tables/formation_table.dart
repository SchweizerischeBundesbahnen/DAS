// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/data/local/formation_database_service_impl.dart';

class FormationTable extends Table {
  TextColumn get operationalTrainNumber => text()();

  TextColumn get company => text()();

  DateTimeColumn get operationalDay => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {operationalTrainNumber, company, operationalDay};
}

extension FormationMapperX on FormationDto {
  FormationTableCompanion toCompanion() {
    return FormationTableCompanion.insert(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
    );
  }
}

extension FormationTableDataX on FormationTableData {
  FormationDto toDomain() {
    return FormationDto(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
    );
  }
}

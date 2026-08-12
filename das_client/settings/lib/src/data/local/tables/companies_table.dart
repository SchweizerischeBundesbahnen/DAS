// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:settings/src/api/dto/company_dto.dart';
import 'package:settings/src/data/local/settings_database_service.dart';

class CompaniesTable extends Table {
  TextColumn get code => text()();

  TextColumn get shortName => text()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}

extension CompaniesMapperX on CompanyDto {
  CompaniesTableCompanion toCompanion() {
    return CompaniesTableCompanion.insert(code: code, shortName: shortName);
  }
}

extension CompaniesTableDataX on CompaniesTableData {
  CompanyDto toDto() => CompanyDto(code: code, shortName: shortName);
}

// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/data/local/settings_database_service.dart';

class RuFeaturesTable extends Table {
  TextColumn get companyCodeRics => text()();

  TextColumn get key => text()();

  BoolColumn get enabled => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {companyCodeRics, key};
}

extension RuFeaturesMapperX on RuFeatureDto {
  RuFeaturesTableCompanion toCompanion() {
    return RuFeaturesTableCompanion.insert(
      companyCodeRics: companyCodeRics,
      key: key,
      enabled: enabled,
    );
  }
}

extension RuFeaturesTableDataX on RuFeaturesTableData {
  RuFeatureDto toDomain() {
    return RuFeatureDto(companyCodeRics: companyCodeRics, key: key, enabled: enabled);
  }
}

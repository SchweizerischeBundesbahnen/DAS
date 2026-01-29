// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';
import 'package:settings/src/data/local/tables/ru_features_table.dart';
import 'package:settings/src/model/ru_feature_keys.dart';

part 'settings_database_service.g.dart';

@DriftDatabase(
  tables: [
    RuFeaturesTable,
  ],
)
class SettingsDatabaseService extends _$SettingsDatabaseService implements RuFeatureDatabaseService {
  static SettingsDatabaseService? _instance;

  static SettingsDatabaseService get instance {
    _instance ??= SettingsDatabaseService._();
    return _instance!;
  }

  SettingsDatabaseService._() : super(driftDatabase(name: 'settings_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  @override
  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey) async {
    final featureData = await _manager
        .filter((f) => f.companyCodeRics(companyCodeRics) & f.key(featureKey.key))
        .getSingleOrNull();
    return featureData?.toDomain();
  }

  @override
  Future<void> saveRuFeatures(List<RuFeatureDto> ruFeatures) async =>
      _manager.bulkCreate((_) => ruFeatures.map((element) => element.toCompanion()), mode: InsertMode.insertOrReplace);

  $$RuFeaturesTableTableTableManager get _manager => managers.ruFeaturesTable;
}

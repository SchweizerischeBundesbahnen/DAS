// coverage:ignore-file

import 'package:app/api/dto/ru_feature_dto.dart';
import 'package:app/data/local/ru_feature_database_service.dart';
import 'package:app/data/local/tables/ru_features_table.dart';
import 'package:app/model/ru_feature_keys.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'das_database_service.g.dart';

@DriftDatabase(
  tables: [
    RuFeaturesTable,
  ],
)
class DASDatabaseService extends _$DASDatabaseService implements RuFeatureDatabaseService {
  static DASDatabaseService? _instance;

  static DASDatabaseService get instance {
    _instance ??= DASDatabaseService._();
    return _instance!;
  }

  DASDatabaseService._() : super(driftDatabase(name: 'das_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }

  @override
  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey) async {
    final tableData =
        await (select(ruFeaturesTable)
              ..where((tbl) => tbl.companyCodeRics.equals(companyCodeRics))
              ..where((tbl) => tbl.key.equals(featureKey.key)))
            .get();

    return tableData.map((it) => it.toDomain()).firstOrNull;
  }

  @override
  Future<void> saveRuFeatures(List<RuFeatureDto> ruFeatures) async {
    for (final ruFeature in ruFeatures) {
      await ruFeaturesTable.insertOnConflictUpdate(ruFeature.toCompanion());
    }
  }
}

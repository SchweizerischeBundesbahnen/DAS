// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:settings/src/api/dto/company_dto.dart';
import 'package:settings/src/api/dto/ru_feature_dto.dart';
import 'package:settings/src/data/local/ru_feature_database_service.dart';
import 'package:settings/src/data/local/tables/companies_table.dart';
import 'package:settings/src/data/local/tables/ru_features_table.dart';
import 'package:settings/src/model/ru_feature_keys.dart';

part 'settings_database_service.g.dart';

@DriftDatabase(
  tables: [
    RuFeaturesTable,
    CompaniesTable,
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.create(companiesTable);
      }
    },
  );

  @override
  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey) async {
    final featureData = await _ruFeatureTableManager
        .filter((f) => f.companyCodeRics(companyCodeRics) & f.key(featureKey.key))
        .getSingleOrNull();
    return featureData?.toDto();
  }

  @override
  Future<void> replaceAllRuFeatures(List<RuFeatureDto> ruFeatures) async {
    return transaction(() async {
      await _ruFeatureTableManager.delete();
      await _ruFeatureTableManager.bulkCreate(
        (_) => ruFeatures.map((element) => element.toCompanion()),
        mode: .insertOrReplace,
      );
    });
  }

  @override
  Future<List<CompanyDto>> findAllCompanies() async {
    final companies = await _companiesTableManager.get();
    return companies.map((company) => company.toDto()).toList(growable: false);
  }

  @override
  Future<CompanyDto?> findCompany(String companyCode) async {
    final featureData = await _companiesTableManager.filter((company) => company.code(companyCode)).getSingleOrNull();
    return featureData?.toDto();
  }

  @override
  Future<void> replaceAllCompanies(List<CompanyDto> companies) async {
    return transaction(() async {
      await _companiesTableManager.delete();
      await _companiesTableManager.bulkCreate(
        (_) => companies.map((element) => element.toCompanion()),
        mode: .insertOrFail,
      );
    });
  }

  $$RuFeaturesTableTableTableManager get _ruFeatureTableManager => managers.ruFeaturesTable;

  $$CompaniesTableTableTableManager get _companiesTableManager => managers.companiesTable;
}

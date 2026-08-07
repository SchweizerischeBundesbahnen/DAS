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
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  @override
  Future<RuFeatureDto?> findRuFeature(String companyCodeRics, RuFeatureKeys featureKey) async {
    final featureData = await _ruFeaturesManager
        .filter((f) => f.companyCodeRics(companyCodeRics) & f.key(featureKey.key))
        .getSingleOrNull();
    return featureData?.toDto();
  }

  @override
  Future<List<CompanyDto>> findAllCompanies() async {
    final companies = await _companiesManager.get();
    return companies.map((company) => company.toDto()).toList(growable: false);
  }

  @override
  Future<CompanyDto?> findCompany(String companyCode) async {
    final featureData = await _companiesManager.filter((company) => company.code(companyCode)).getSingleOrNull();
    return featureData?.toDto();
  }

  @override
  Future<void> saveRuFeatures(List<RuFeatureDto> ruFeatures) async => _ruFeaturesManager.bulkCreate(
    (_) => ruFeatures.map((element) => element.toCompanion()),
    mode: InsertMode.insertOrReplace,
  );

  @override
  Future<void> saveCompanies(List<CompanyDto> companies) async => _companiesManager.bulkCreate(
    (_) => companies.map((element) => element.toCompanion()),
    mode: InsertMode.insertOrReplace,
  );

  $$RuFeaturesTableTableTableManager get _ruFeaturesManager => managers.ruFeaturesTable;

  $$CompaniesTableTableTableManager get _companiesManager => managers.companiesTable;
}

// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/data/local/formation_database_service.dart';
import 'package:formation/src/data/local/tables/formation_table.dart';
import 'package:formation/src/model/formation.dart';

part 'formation_database_service_impl.g.dart';

@DriftDatabase(
  tables: [
    FormationTable,
  ],
)
class FormationDatabaseServiceImpl extends _$FormationDatabaseServiceImpl implements FormationDatabaseService {
  static FormationDatabaseService? _instance;

  static FormationDatabaseService get instance {
    _instance ??= FormationDatabaseServiceImpl._();
    return _instance!;
  }

  FormationDatabaseServiceImpl._() : super(driftDatabase(name: 'formation_db'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        for (final entity in m.database.allSchemaEntities) {
          await m.drop(entity);
        }

        await m.createAll();
      },
    );
  }

  @override
  Stream<Formation?> watchFormation(String operationalTrainNumber, String company, DateTime operationalDay) {
    return _manager
        .filter(
          (f) =>
              f.operationalTrainNumber(operationalTrainNumber) & f.company(company) & f.operationalDay(operationalDay),
        )
        .watchSingleOrNull()
        .map((it) => it?.toDomain());
  }

  @override
  Future<void> saveFormation(FormationDto formation, {String? etag}) async {
    await formationTable.insertOnConflictUpdate(formation.toCompanion(etag));
  }

  @override
  Future<String?> findFormationEtag(String operationalTrainNumber, String company, DateTime operationalDay) {
    return _manager
        .filter(
          (f) =>
              f.operationalTrainNumber(operationalTrainNumber) & f.company(company) & f.operationalDay(operationalDay),
        )
        .getSingleOrNull()
        .then((it) => it?.etag);
  }

  @override
  Future<Formation?> findFormation(String operationalTrainNumber, String company, DateTime operationalDay) async {
    return _manager
        .filter(
          (f) =>
              f.operationalTrainNumber(operationalTrainNumber) & f.company(company) & f.operationalDay(operationalDay),
        )
        .getSingleOrNull()
        .then((it) => it?.toDomain());
  }

  $$FormationTableTableTableManager get _manager => managers.formationTable;
}

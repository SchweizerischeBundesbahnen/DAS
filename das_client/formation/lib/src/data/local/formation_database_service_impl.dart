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
  Stream<Formation?> watchFormation(String operationalTrainNumber, String company, DateTime operationalDay) {
    return (select(formationTable)
          ..where((tbl) => tbl.operationalTrainNumber.equals(operationalTrainNumber))
          ..where((tbl) => tbl.company.equals(company))
          ..where((tbl) => tbl.operationalDay.equals(operationalDay)))
        .watchSingleOrNull()
        .map((it) => it?.toDomain());
  }

  @override
  Future<void> saveFormation(FormationDto formation) async {
    await formationTable.insertOnConflictUpdate(formation.toCompanion());
  }
}

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/otn_id_dto.dart';
import 'package:sfera/src/data/dto/train_identification_dto.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  group('DriftSferaLocalDatabaseService', () {
    late DriftSferaLocalDatabaseService db;

    setUp(() {
      db = DriftSferaLocalDatabaseService.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    JourneyProfileDto createJourneyProfile({
      required int version,
      required String company,
      required String trainNumber,
      required DateTime startDate,
    }) {
      return JourneyProfileDto.create(
        version: version,
        trainIdentification: TrainIdentificationDto.create(
          otnId: OtnIdDto.create(company, trainNumber, startDate),
        ),
        segmentProfileReferences: const [],
        generalJpInformation: null,
      );
    }

    test('schemaVersion_whenQueried_thenReturns5', () {
      // GIVEN / WHEN / THEN
      expect(db.schemaVersion, 5);
    });

    test('findJourneyProfile_whenMultipleVersionsExist_thenReturnsHighestVersion', () async {
      // GIVEN
      final company = '1085';
      final trainNumber = '719';
      final startDate = DateTime(2026, 1, 1);

      await db.saveJourneyProfile(
        createJourneyProfile(version: 2, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 9, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 10, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 100, company: company, trainNumber: trainNumber, startDate: startDate),
      );

      // WHEN
      final result = await db.findJourneyProfile(company, trainNumber, startDate);

      // THEN
      expect(result, isNotNull);
      expect(result!.version, 100);
    });

    test('observeJourneyProfile_whenMultipleVersionsExist_thenEmitsHighestVersion', () async {
      // GIVEN
      final company = '1085';
      final trainNumber = '719';
      final startDate = DateTime(2026, 1, 1);

      await db.saveJourneyProfile(
        createJourneyProfile(version: 2, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 9, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 10, company: company, trainNumber: trainNumber, startDate: startDate),
      );
      await db.saveJourneyProfile(
        createJourneyProfile(version: 100, company: company, trainNumber: trainNumber, startDate: startDate),
      );

      // WHEN
      final result = await db.observeJourneyProfile(company, trainNumber, startDate).first;

      // THEN
      expect(result, isNotNull);
      expect(result!.version, 100);
    });

    test('migration_whenUpgradingFromSchema4To5_thenMigratesVersionToIntAndPreservesData', () async {
      // GIVEN
      final company = '1085';
      final trainNumber = '719';
      final startDate = DateTime(2026, 1, 1);
      final jp9 = createJourneyProfile(version: 9, company: company, trainNumber: trainNumber, startDate: startDate);
      final jp10 = createJourneyProfile(
        version: 10,
        company: company,
        trainNumber: trainNumber,
        startDate: startDate,
      );

      final executor = NativeDatabase.memory(
        setup: (rawDb) {
          rawDb.execute('''
            CREATE TABLE journey_profile_table (
              version TEXT NOT NULL,
              company TEXT NOT NULL,
              operational_train_number TEXT NOT NULL,
              start_date INTEGER NOT NULL,
              xml_data TEXT NOT NULL,
              PRIMARY KEY (company, operational_train_number, start_date, version)
            );
            CREATE TABLE acknowledged_modification_table (
              identifier TEXT NOT NULL,
              date INTEGER NOT NULL,
              type TEXT NOT NULL,
              PRIMARY KEY (identifier, date, type)
            );
            CREATE TABLE segment_profile_table (
              sp_id TEXT NOT NULL,
              major_version TEXT NOT NULL,
              minor_version TEXT NOT NULL,
              xml_data TEXT NOT NULL,
              PRIMARY KEY (sp_id, major_version, minor_version)
            );
            CREATE TABLE train_characteristics_table (
              tc_id TEXT NOT NULL,
              major_version TEXT NOT NULL,
              minor_version TEXT NOT NULL,
              xml_data TEXT NOT NULL,
              PRIMARY KEY (tc_id, major_version, minor_version)
            );
            PRAGMA user_version = 4;
          ''');
          rawDb.execute(
            'INSERT INTO journey_profile_table (version, company, operational_train_number, start_date, xml_data) VALUES (?, ?, ?, ?, ?);',
            ['9', company, trainNumber, startDate.millisecondsSinceEpoch ~/ 1000, jp9.buildDocument().toString()],
          );
          rawDb.execute(
            'INSERT INTO journey_profile_table (version, company, operational_train_number, start_date, xml_data) VALUES (?, ?, ?, ?, ?);',
            ['10', company, trainNumber, startDate.millisecondsSinceEpoch ~/ 1000, jp10.buildDocument().toString()],
          );
        },
      );

      final migratedDb = DriftSferaLocalDatabaseService.forTesting(executor);

      // WHEN
      final result = await migratedDb.findJourneyProfile(company, trainNumber, startDate);

      // THEN
      expect(result, isNotNull);
      expect(result!.version, 10);

      await migratedDb.close();
    });
  });
}

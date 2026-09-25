import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';

void main() {
  late DriftSferaLocalDatabaseService testee;

  setUp(() {
    testee = DriftSferaLocalDatabaseService.test(NativeDatabase.memory());
  });

  tearDown(() async {
    await testee.close();
  });

  test('saveModification stores a modification only once and deleteModification removes it', () async {
    final modification = Modification(
      identifier: 'CH00300T35_1_Normal_station',
      date: DateTime(2026, 9, 25),
      type: ModificationType.updated,
    );

    await testee.saveModification(modification);
    await testee.saveModification(modification);

    final savedModifications = await testee.observeModifications().firstWhere((items) => items.isNotEmpty);
    expect(savedModifications, [modification]);

    await testee.deleteModification(modification);

    final remainingModifications = await testee.observeModifications().first;
    expect(remainingModifications, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/repository/acknowledged_modification_repository_impl.dart';

import 'acknowledged_modification_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaLocalDatabaseService>(),
])
void main() {
  late AcknowledgedModificationRepository testee;
  late MockSferaLocalDatabaseService localService;
  late BehaviorSubject<Set<Modification>> modificationsSubject;

  setUp(() {
    localService = MockSferaLocalDatabaseService();
    modificationsSubject = BehaviorSubject.seeded(const <Modification>{});
    when(localService.observeModifications()).thenAnswer((_) => modificationsSubject.stream);
    testee = AcknowledgedModificationRepositoryImpl(databaseService: localService);
  });

  tearDown(() async {
    await modificationsSubject.close();
  });

  test('modificationsStream_whenPersistedModificationsChange_thenEmitsModifications', () async {
    final modification = Modification(
      identifier: 'signal-1',
      date: DateTime(2026, 9, 25),
      type: ModificationType.updated,
    );

    final expectation = expectLater(testee.model.skip(1), emits({modification}));
    modificationsSubject.add({modification});
    await expectation;
  });

  test('insert_whenCalled_thenDelegatesToLocalDatabaseService', () async {
    final modification = Modification(
      identifier: 'signal-1',
      date: DateTime(2026, 9, 25),
      type: ModificationType.updated,
    );

    await testee.insert(modification);

    verify(localService.saveModification(modification)).called(1);
  });

  test('delete_whenCalled_thenDelegatesToLocalDatabaseService', () async {
    final modification = Modification(
      identifier: 'signal-1',
      date: DateTime(2026, 9, 25),
      type: ModificationType.updated,
    );

    await testee.delete(modification);

    verify(localService.deleteModification(modification)).called(1);
  });

  group('cleanup on insert', () {
    test('insert_whenCalledForFirstTimeOfDay_thenDeletesModificationsOlderThanShowModificationDays', () async {
      final baseDate = DateTime(2026, 9, 28, 12);

      final oldModification = Modification(
        identifier: 'old-signal',
        date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays + 1)),
        type: ModificationType.updated,
      );
      final recentModification = Modification(
        identifier: 'recent-signal',
        date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays - 1)),
        type: ModificationType.updated,
      );

      modificationsSubject.add({oldModification, recentModification});

      testee = AcknowledgedModificationRepositoryImpl(
        databaseService: localService,
      );

      final newModification = Modification(
        identifier: 'new-signal',
        date: baseDate,
        type: ModificationType.updated,
      );

      await testee.insert(newModification);

      verify(localService.deleteExpiredModification(any)).called(1);
      verifyNever(localService.deleteModification(recentModification));
      verify(localService.saveModification(newModification)).called(1);
    });

    test('insert_whenCalledSecondTimeOnSameDay_thenDoesNotDeleteModificationsAgain', () async {
      final baseDate = DateTime(2026, 9, 28, 12);
      var currentDate = baseDate;

      final oldModification = Modification(
        identifier: 'old-signal',
        date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays + 1)),
        type: ModificationType.updated,
      );

      modificationsSubject.add({oldModification});

      testee = AcknowledgedModificationRepositoryImpl(
        databaseService: localService,
      );

      final firstModification = Modification(
        identifier: 'first-signal',
        date: currentDate,
        type: ModificationType.updated,
      );
      final secondModification = Modification(
        identifier: 'second-signal',
        date: currentDate.add(const Duration(hours: 2)),
        type: ModificationType.updated,
      );

      await testee.insert(firstModification);
      verify(localService.deleteExpiredModification(any)).called(1);
      clearInteractions(localService);

      currentDate = currentDate.add(const Duration(hours: 2));
      await testee.insert(secondModification);

      verifyNever(localService.deleteModification(any));
      verify(localService.saveModification(secondModification)).called(1);
    });
  });
}

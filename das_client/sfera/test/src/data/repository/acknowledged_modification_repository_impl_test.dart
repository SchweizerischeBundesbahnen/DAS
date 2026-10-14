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
    final modification = Modification(identifier: 'signal-1', date: DateTime(2026, 9, 25), type: .updated);

    final expectation = expectLater(testee.model.skip(1), emits({modification}));
    modificationsSubject.add({modification});
    await expectation;
  });

  test('insert_whenCalled_thenDelegatesToLocalDatabaseService', () async {
    final modification = Modification(identifier: 'signal-1', date: DateTime(2026, 9, 25), type: .updated);

    await testee.insert(modification);

    verify(localService.saveModification(modification)).called(1);
  });

  test('delete_whenCalled_thenDelegatesToLocalDatabaseService', () async {
    final modification = Modification(identifier: 'signal-1', date: DateTime(2026, 9, 25), type: .updated);

    await testee.delete(modification);

    verify(localService.deleteModification(modification)).called(1);
  });

  test(
    'deleteExpiredModifications_whenCalledForFirstTimeOfDay_thenDeletesModificationsOlderThanShowModificationDays',
    () async {
      // GIVEN
      final baseDate = DateTime(2026, 9, 28, 12);
      final oldModification = Modification(
        identifier: 'old-signal',
        date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays + 1)),
        type: .updated,
      );
      final recentModification = Modification(
        identifier: 'recent-signal',
        date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays - 1)),
        type: .updated,
      );
      modificationsSubject.add({oldModification, recentModification});

      // WHEN
      await testee.deleteExpiredModifications();

      // THEN
      verify(localService.deleteExpiredModification(any)).called(1);
      verifyNever(localService.deleteModification(recentModification));
    },
  );

  test('deleteExpiredModifications_whenCalledSecondTimeOnSameDay_thenDoesNotDeleteModificationsAgain', () async {
    // GIVEN
    final baseDate = DateTime(2026, 9, 28, 12);
    final oldModification = Modification(
      identifier: 'old-signal',
      date: baseDate.subtract(const Duration(days: JourneyPoint.showModificationDays + 1)),
      type: .updated,
    );
    modificationsSubject.add({oldModification});

    // WHEN THEN first time
    await testee.deleteExpiredModifications();
    verify(localService.deleteExpiredModification(any)).called(1);
    clearInteractions(localService);

    // WHEN THEN second time
    modificationsSubject.add({oldModification});
    await testee.deleteExpiredModifications();
    verifyNever(localService.deleteModification(any));
  });
}

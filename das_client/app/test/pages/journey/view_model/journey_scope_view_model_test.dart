import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/pages/journey/view_model/journey_scope_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import 'journey_scope_view_model_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ScopeHandler>()])
void main() {
  group('JourneyScopeViewModel', () {
    late JourneyScopeViewModel testee;
    late MockScopeHandler mockScopeHandler;
    late PublishSubject<void> scopeChangedSubject;

    setUp(() {
      mockScopeHandler = MockScopeHandler();
      scopeChangedSubject = PublishSubject<void>();
      when(mockScopeHandler.onScopeChanged).thenAnswer((_) => scopeChangedSubject.stream);
    });

    tearDown(() async {
      testee.dispose();
      await scopeChangedSubject.close();
    });

    test('initialState_whenJourneyScopeNotInStack_thenIsFalse', () {
      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(false);

      testee = JourneyScopeViewModel(scopeHandler: mockScopeHandler);

      expect(testee.isJourneyScopeActiveValue, isFalse);
      expect(testee.modelValue, isFalse);
    });

    test('initialState_whenJourneyScopeInStack_thenIsTrue', () {
      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(true);

      testee = JourneyScopeViewModel(scopeHandler: mockScopeHandler);

      expect(testee.isJourneyScopeActiveValue, isTrue);
      expect(testee.modelValue, isTrue);
    });

    test('stream_whenScopeChanges_thenEmitsUpdatedState', () async {
      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(false);
      testee = JourneyScopeViewModel(scopeHandler: mockScopeHandler);

      final emissions = <bool>[];
      final sub = testee.isJourneyScopeActive.listen(emissions.add);

      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(true);
      scopeChangedSubject.add(null);
      await pumpEventQueue();

      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(false);
      scopeChangedSubject.add(null);
      await pumpEventQueue();

      expect(emissions, [false, true, false]);
      await sub.cancel();
    });

    test('stream_whenDistinctScopeStateEmitted_thenDoesNotEmitDuplicates', () async {
      when(mockScopeHandler.isInStack<JourneyScope>()).thenReturn(false);
      testee = JourneyScopeViewModel(scopeHandler: mockScopeHandler);

      final emissions = <bool>[];
      final sub = testee.isJourneyScopeActive.listen(emissions.add);

      scopeChangedSubject.add(null);
      await pumpEventQueue();

      expect(emissions, [false]);
      await sub.cancel();
    });
  });
}

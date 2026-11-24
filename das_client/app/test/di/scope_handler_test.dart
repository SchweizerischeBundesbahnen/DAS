import 'package:app/di/di.dart';
import 'package:app/di/scope_handler_impl.dart';
import 'package:app/flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'scope_handler_test.mocks.dart';

@GenerateNiceMocks([MockSpec<DASBaseScope>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ScopeHandler', () {
    const dasBaseScopeName = 'DASBaseScope';
    late ScopeHandlerImpl testee;
    late DASBaseScope mockDASBaseScope;

    setUp(() async {
      await GetIt.I.reset();
      testee = ScopeHandlerImpl();
      mockDASBaseScope = MockDASBaseScope();
      when(mockDASBaseScope.scopeName).thenReturn(dasBaseScopeName);

      GetIt.I.registerFlavor(Flavor.dev());
      GetIt.I.registerSingleton<DASBaseScope>(mockDASBaseScope);
    });

    test('push_whenInvalidScope_thenThrows', () {
      // WHEN & THEN
      expect(() => testee.push<DIScope>(), throwsA(isA<UnimplementedError>()));
    });

    test('push_whenBaseScopePushed_thenCallsPush', () async {
      // GIVEN
      when(mockDASBaseScope.push()).thenAnswer((_) async {});
      // WHEN
      await testee.push<DASBaseScope>();
      // THEN
      verify(mockDASBaseScope.push()).called(1);
    });

    test('pop_whenBaseScopePopped_thenCallsPop', () async {
      // GIVEN
      when(mockDASBaseScope.pop()).thenAnswer((_) async => true);
      // WHEN
      final result = await testee.pop<DASBaseScope>();
      // THEN
      verify(mockDASBaseScope.pop()).called(1);
      expect(result, isTrue);
    });

    test('popAbove_whenBaseScopePoppedAbove_thenCallsPopAbove', () async {
      // GIVEN
      when(mockDASBaseScope.popAbove()).thenAnswer((_) async => true);
      // WHEN
      final result = await testee.popAbove<DASBaseScope>();
      // THEN
      verify(mockDASBaseScope.popAbove()).called(1);
      expect(result, isTrue);
    });

    test('isInStack_whenBaseScopeIsInGetItAndNameReturned_thenReturnsTrue', () async {
      // GIVEN
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);

      // WHEN & THEN
      expect(testee.isInStack<DASBaseScope>(), isTrue);
    });

    test('isInStack_whenBaseScopeIsNotInGetIt_thenReturnsFalse', () async {
      // WHEN & THEN
      expect(testee.isInStack<DASBaseScope>(), isFalse);
    });

    test('isTop_whenBaseScopeIsTop_thenReturnsTrue', () async {
      // GIVEN
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);

      // WHEN & THEN
      expect(testee.isTop<DASBaseScope>(), isTrue);
    });

    test('isTop_whenBaseScopeIsNotTop_thenReturnsFalse', () async {
      // GIVEN
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);
      GetIt.I.pushNewScope(scopeName: 'AnotherScope');

      // WHEN & THEN
      expect(testee.isTop<DASBaseScope>(), isFalse);
    });

    test('onScopeChanged_whenScopePushedOrPopped_thenEmits', () async {
      when(mockDASBaseScope.push()).thenAnswer((_) async {});
      when(mockDASBaseScope.pop()).thenAnswer((_) async => true);

      var emitCount = 0;
      final sub = testee.onScopeChanged.listen((_) => emitCount++);

      await testee.push<DASBaseScope>();
      await pumpEventQueue();
      await testee.pop<DASBaseScope>();
      await pumpEventQueue();

      expect(emitCount, 2);
      await sub.cancel();
    });
  });
}

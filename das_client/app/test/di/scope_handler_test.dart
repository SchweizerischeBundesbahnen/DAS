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
      testee = ScopeHandlerImpl();
      mockDASBaseScope = MockDASBaseScope();
      when(mockDASBaseScope.scopeName).thenReturn(dasBaseScopeName);

      await GetIt.I.reset();
      GetIt.I.registerFlavor(Flavor.dev());
      GetIt.I.registerSingleton<DASBaseScope>(mockDASBaseScope);
    });

    test('push_whenInvalidScope_thenThrows', () {
      // ACT & EXPECT
      expect(() => testee.push<DIScope>(), throwsA(isA<UnimplementedError>()));
    });

    test('push_whenBaseScopePushed_thenCallsPush', () async {
      // ARRANGE
      when(mockDASBaseScope.push()).thenAnswer((_) async {});
      // ACT
      await testee.push<DASBaseScope>();
      // EXPECT
      verify(mockDASBaseScope.push()).called(1);
    });

    test('pop_whenBaseScopePopped_thenCallsPop', () async {
      // ARRANGE
      when(mockDASBaseScope.pop()).thenAnswer((_) async => true);
      // ACT
      final result = await testee.pop<DASBaseScope>();
      // EXPECT
      verify(mockDASBaseScope.pop()).called(1);
      expect(result, isTrue);
    });

    test('popAbove_whenBaseScopePoppedAbove_thenCallsPopAbove', () async {
      // ARRANGE
      when(mockDASBaseScope.popAbove()).thenAnswer((_) async => true);
      // ACT
      final result = await testee.popAbove<DASBaseScope>();
      // EXPECT
      verify(mockDASBaseScope.popAbove()).called(1);
      expect(result, isTrue);
    });

    test('isInStack_whenBaseScopeIsInGetItAndNameReturned_thenReturnsTrue', () async {
      // ARRANGE
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);

      // ACT & EXPECT
      expect(testee.isInStack<DASBaseScope>(), isTrue);
    });

    test('isInStack_whenBaseScopeIsNotInGetIt_thenReturnsFalse', () async {
      // ACT & EXPECT
      expect(testee.isInStack<DASBaseScope>(), isFalse);
    });

    test('isTop_whenBaseScopeIsTop_thenReturnsTrue', () async {
      // ARRANGE
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);

      // ACT & EXPECT
      expect(testee.isTop<DASBaseScope>(), isTrue);
    });

    test('isTop_whenBaseScopeIsNotTop_thenReturnsFalse', () async {
      // ARRANGE
      GetIt.I.pushNewScope(scopeName: dasBaseScopeName);
      GetIt.I.pushNewScope(scopeName: 'AnotherScope');

      // ACT & EXPECT
      expect(testee.isTop<DASBaseScope>(), isFalse);
    });
  });
}

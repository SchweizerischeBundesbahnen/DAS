import 'package:user_properties/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:user_properties/src/api/user_properties_api_service.dart';
import 'package:user_properties/src/repository/user_properties_repository_impl.dart';
import 'package:user_properties/src/repository/user_properties_syncer.dart';

import 'user_properties_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPropertiesApiService>(),
  MockSpec<LocalKeyValueStore>(),
])
void main() {
  late MockUserPropertiesApiService apiService;
  late UserPropertiesRepositoryImpl repository;
  late MockLocalKeyValueStore localStore;

  setUp(() {
    apiService = MockUserPropertiesApiService();
    localStore = MockLocalKeyValueStore();
    repository = UserPropertiesRepositoryImpl(
      apiService: apiService,
      localStore: localStore,
    );
  });

  UserPropertyModel p(String key, int ms) => UserPropertyModel(
    key: key,
    value: 'x',
    lastUpdated: DateTime.fromMillisecondsSinceEpoch(ms),
  );

  test('neuere Seite gewinnt, fehlende Seite verliert immer', () {
    final plan = planSync(
      {'A': p('A', 100), 'B': p('B', 50), 'D': p('D', 70), 'E': p('E', 40)},
      {'A': p('A', 80), 'B': p('B', 90), 'C': p('C', 60), 'D': p('D', 70)},
    );

    expect(plan.push.map((e) => e.key), unorderedEquals(['A', 'E']));
    expect(plan.pull.map((e) => e.key), unorderedEquals(['B', 'C']));
  });

  /*test('getAllUserPropertiesCorrectly_atAppStart', () async {
    when(apiService.userProperties())
  });

  test('findTrainIdentifications_whenApiCallFails_thenFallsBackToLocalDatabase', () async {
    when(apiService.companies).thenReturn(request);
    when(
      request.call(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDates: anyNamed('startDates'),
      ),
    ).thenThrow(Exception('network error'));

    when(
      sferaLocalRepo.findCompanyMatchesByTrainNumber(
        '12345',
        startDates: anyNamed('startDates'),
      ),
    ).thenAnswer(
      (_) async => {
        CompanyMatch(
          companyCode: '1285',
          startDate: DateTime(2026, 7, 21),
        ),
      },
    );

    final result = await repository.findTrainIdentifications(operationalTrainNumber: '12345');

    expect(result, hasLength(1));
    expect(result.first.companyCode, '1285');
    expect(result.first.startDate, DateTime(2026, 7, 21));
    verify(
      sferaLocalRepo.findCompanyMatchesByTrainNumber(
        '12345',
        startDates: anyNamed('startDates'),
      ),
    ).called(1);
  });*/
}

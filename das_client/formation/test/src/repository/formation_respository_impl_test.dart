import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/api/dto/formation_response_dto.dart';
import 'package:formation/src/api/endpoint/formation.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:formation/src/data/local/formation_database_service.dart';
import 'package:formation/src/repository/formation_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formation_respository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FormationApiService>(),
  MockSpec<FormationDatabaseService>(),
  MockSpec<FormationRequest>(),
])
void main() {
  late FormationRepository testee;
  late MockFormationApiService mockApiService;
  late MockFormationDatabaseService mockDatabaseService;
  late MockFormationRequest mockFormationRequest;

  setUp(() {
    mockApiService = MockFormationApiService();
    mockDatabaseService = MockFormationDatabaseService();
    mockFormationRequest = MockFormationRequest();

    testee = FormationRepositoryImpl(
      apiService: mockApiService,
      databaseService: mockDatabaseService,
    );
  });

  test('watchFormation_whenCalled_thenCallsWatchFormationOnDatabaseService', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    // ACT
    testee.watchFormation(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
    );

    // VERIFY
    verify(
      mockDatabaseService.watchFormation(operationalTrainNumber, company, operationalDay),
    ).called(1);
  });

  test('whenWatchFormation_thenCallApiServiceAndSaveToDatabase', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    when(
      mockApiService.formation(operationalTrainNumber, company, operationalDay),
    ).thenAnswer((_) => mockFormationRequest);
    when(mockFormationRequest.call()).thenAnswer(
      (_) => Future.value(
        FormationResponse(
          headers: {},
          body: FormationResponseDto(
            data: [
              FormationDto(
                operationalTrainNumber: operationalTrainNumber,
                company: company,
                operationalDay: operationalDay,
                formationRuns: [],
              ),
            ],
          ),
        ),
      ),
    );

    // ACT
    testee.watchFormation(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
    );

    await Future.delayed(Duration.zero);

    // VERIFY
    verify(
      mockDatabaseService.saveFormation(any),
    ).called(1);
    verify(
      mockApiService.formation(operationalTrainNumber, company, operationalDay),
    ).called(1);
  });

  test('whenWatchFormation_thenCallApiServiceAndDoNotSaveNullResponseToDatabase', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    // ACT
    when(
      mockApiService.formation(operationalTrainNumber, company, operationalDay),
    ).thenAnswer((_) => mockFormationRequest);
    when(mockFormationRequest.call()).thenAnswer(
      (_) => Future.value(
        FormationResponse(
          headers: {},
          body: null,
        ),
      ),
    );

    // VERIFY
    testee.watchFormation(
      operationalTrainNumber: operationalTrainNumber,
      company: company,
      operationalDay: operationalDay,
    );

    verifyNever(
      mockDatabaseService.saveFormation(any),
    );
    verify(
      mockApiService.formation(operationalTrainNumber, company, operationalDay),
    ).called(1);
  });
}

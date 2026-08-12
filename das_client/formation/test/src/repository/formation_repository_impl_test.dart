import 'package:flutter_test/flutter_test.dart';
import 'package:formation/component.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/api/dto/formation_response_dto.dart';
import 'package:formation/src/api/endpoint/formation.dart';
import 'package:formation/src/api/endpoint/transport_paper.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:formation/src/data/local/formation_database_service.dart';
import 'package:formation/src/repository/formation_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formation_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FormationApiService>(),
  MockSpec<FormationDatabaseService>(),
  MockSpec<FormationRequest>(),
  MockSpec<TransportPaperRequest>(),
])
void main() {
  late FormationRepository testee;
  late MockFormationApiService mockApiService;
  late MockFormationDatabaseService mockDatabaseService;
  late MockFormationRequest mockFormationRequest;
  late MockTransportPaperRequest mockTransportPaperRequest;

  setUp(() {
    mockApiService = MockFormationApiService();
    mockDatabaseService = MockFormationDatabaseService();
    mockFormationRequest = MockFormationRequest();
    mockTransportPaperRequest = MockTransportPaperRequest();

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
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
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
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
    ).called(1);
  });

  test('whenWatchFormation_thenCallApiServiceAndDoNotSaveNullResponseToDatabase', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    // ACT
    when(
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
    ).thenAnswer((_) => mockFormationRequest);
    when(
      mockDatabaseService.findFormationEtag(operationalTrainNumber, company, operationalDay),
    ).thenAnswer((_) => Future.value(null));
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

    await Future.delayed(Duration(milliseconds: 10));

    verifyNever(
      mockDatabaseService.saveFormation(any),
    );
    verify(
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
    ).called(1);
  });

  test('whenWatchFormation_thenCallApiServiceAndDeleteLocalDataOn404', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    // ACT
    when(
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
    ).thenAnswer((_) => mockFormationRequest);
    when(
      mockDatabaseService.findFormationEtag(operationalTrainNumber, company, operationalDay),
    ).thenAnswer((_) => Future.value(null));
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

    await Future.delayed(Duration(milliseconds: 10));

    verify(mockDatabaseService.deleteFormation(operationalTrainNumber, company, operationalDay)).called(1);
    verify(
      mockApiService.formation(operationalTrainNumber, company, operationalDay, any),
    ).called(1);
  });

  test('resolveTransportPaperLink_whenTypeIsUrl_thenReturnsOriginalUrl', () async {
    // GIVEN
    const url = '/transport/paper/123';
    final transportPaperLink = TransportPaperLink(url: url, type: .url);

    // ACT
    final result = await testee.resolveTransportPaperLink(transportPaperLink);

    // VERIFY
    expect(result, url);
    verifyNever(mockApiService.transportPaper(any));
  });

  test('resolveTransportPaperLink_whenTypeIsPdfRedirect_thenReturnsLocationHeader', () async {
    // GIVEN
    const url = '/transport/paper/redirect';
    const location = 'https://example.com/transport-paper.pdf';
    final transportPaperLink = TransportPaperLink(url: url, type: .pdfRedirect);

    when(mockApiService.transportPaper(url)).thenReturn(mockTransportPaperRequest);
    when(mockTransportPaperRequest.call()).thenAnswer(
      (_) => Future.value(
        const TransportPaperResponse(
          headers: {'location': location},
        ),
      ),
    );

    // ACT
    final result = await testee.resolveTransportPaperLink(transportPaperLink);

    // VERIFY
    expect(result, location);
    verify(mockApiService.transportPaper(url)).called(1);
    verify(mockTransportPaperRequest.call()).called(1);
  });

  test('resolveTransportPaperLink_whenApiCallFails_thenReturnsNull', () async {
    // GIVEN
    const url = '/transport/paper/redirect';
    final transportPaperLink = TransportPaperLink(url: url, type: .pdfRedirect);

    when(mockApiService.transportPaper(url)).thenReturn(mockTransportPaperRequest);
    when(mockTransportPaperRequest.call()).thenThrow(Exception('network error'));

    // ACT
    final result = await testee.resolveTransportPaperLink(transportPaperLink);

    // VERIFY
    expect(result, isNull);
    verify(mockApiService.transportPaper(url)).called(1);
    verify(mockTransportPaperRequest.call()).called(1);
  });
}

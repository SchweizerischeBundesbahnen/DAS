import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ru_indications/src/api/dto/ru_indication_content_dto.dart';
import 'package:ru_indications/src/api/dto/ru_indication_location_dto.dart';
import 'package:ru_indications/src/api/dto/ru_indication_matches_response_dto.dart';
import 'package:ru_indications/src/api/matches/matches_request.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';
import 'package:ru_indications/src/model/ru_indication.dart';
import 'package:ru_indications/src/repository/ru_indications_repository_impl.dart';

import 'ru_indications_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<RuIndicationsApiService>(),
  MockSpec<MatchesRequest>(),
])
void main() {
  late RuIndicationsRepositoryImpl testee;
  late MockRuIndicationsApiService mockRuIndicationsApiService;
  late MockMatchesRequest mockMatchesRequest;

  const company = RailwayUndertaking.sbbP;
  const trainNumber = 12345;
  final startDate = DateTime(2026, 1, 15);
  const Map<String, int> locationReferences = {
    'CH003001': 1000,
    'CH003002': 2000,
  };

  setUp(() {
    mockRuIndicationsApiService = MockRuIndicationsApiService();
    mockMatchesRequest = MockMatchesRequest();
    when(mockRuIndicationsApiService.matches).thenReturn(mockMatchesRequest);
    testee = RuIndicationsRepositoryImpl(
      apiService: mockRuIndicationsApiService,
      retryDelaySeconds: 0, // Use 0 seconds for tests
    );
  });

  test('fetchRuIndications_whenApiCallSucceeds_thenReturnsMappedDomainModels', () async {
    // ARRANGE
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async => MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto()));

    // ACT
    final result = await testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(ru: company, trainNumber: trainNumber.toString(), date: startDate),
          locationReferences: locationReferences,
        )
        .first;

    // EXPECT
    expect(result, equals(_expectedDomainResult()));
  });

  test('fetchRuIndications_whenTrainNumberContainsNonDigits_thenSanitizesTrainNumber', () async {
    // ARRANGE
    const unsanitizedTrainNumber = 'T${trainNumber}M-S19';
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async => MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto()));

    // ACT
    await testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(ru: company, trainNumber: unsanitizedTrainNumber, date: startDate),
          locationReferences: locationReferences,
        )
        .first;

    // EXPECT
    verify(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).called(1);
  });

  test('fetchRuIndications_whenOperatingDayIsSet_thenUsesOperatingDayInsteadOfDate', () async {
    // ARRANGE
    final operatingDay = DateTime(2026, 1, 16, 13, 37);
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: operatingDay,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async => MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto()));

    // ACT
    await testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(
            ru: company,
            trainNumber: trainNumber.toString(),
            date: startDate,
            operatingDay: operatingDay,
          ),
          locationReferences: locationReferences,
        )
        .first;

    // EXPECT
    verify(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: operatingDay,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).called(1);
  });

  test('fetchRuIndications_whenTrainNumberHasNoDigits_thenThrowsFormatException', () async {
    // ARRANGE
    const invalidTrainNumber = 'IC-ABCD';

    // ACT & EXPECT
    await expectLater(
      () => testee
          .fetchRuIndications(
            trainIdentification: TrainIdentification(ru: company, trainNumber: invalidTrainNumber, date: startDate),
            locationReferences: locationReferences,
          )
          .first,
      throwsA(isA<FormatException>()),
    );

    verifyNever(
      mockMatchesRequest.call(
        company: anyNamed('company'),
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
        startDate: anyNamed('startDate'),
        tafTapLocationReferences: anyNamed('tafTapLocationReferences'),
      ),
    );
  });

  test('fetchRuIndications_whenApiCallThrows_thenRetriesIndefinitely', () async {
    // ARRANGE
    var callCount = 0;
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async {
      callCount++;
      throw Exception('Failed');
    });

    // ACT - Subscribe to the stream but don't complete (it retries indefinitely)
    final subscription = testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(ru: company, trainNumber: trainNumber.toString(), date: startDate),
          locationReferences: locationReferences,
        )
        .listen((_) {});

    // Wait for multiple retries to happen
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // EXPECT - Should have been called multiple times due to retries
    expect(callCount, greaterThan(1));

    // Cancel subscription - this stops retrying via onCancel
    await subscription.cancel();
  });

  test('fetchRuIndications_whenApiFailsFirstTimeThenSucceeds_thenReturnsDataAfterRetry', () async {
    // ARRANGE
    var callCount = 0;
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        throw Exception('Temporary failure');
      }
      return MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto());
    });

    // ACT
    final result = await testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(ru: company, trainNumber: trainNumber.toString(), date: startDate),
          locationReferences: locationReferences,
        )
        .first;

    // EXPECT
    expect(callCount, 2);
    expect(result, equals(_expectedDomainResult()));
  });

  test('fetchRuIndications_whenSubscriberCancels_thenRetryStops', () async {
    // ARRANGE
    var callCount = 0;
    when(
      mockMatchesRequest.call(
        company: company.companyCode,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async {
      callCount++;
      throw Exception('Failed');
    });

    // ACT - Subscribe then cancel
    final subscription = testee
        .fetchRuIndications(
          trainIdentification: TrainIdentification(ru: company, trainNumber: trainNumber.toString(), date: startDate),
          locationReferences: locationReferences,
        )
        .listen((_) {});

    await Future<void>.delayed(const Duration(milliseconds: 20));
    final countAtCancel = callCount;
    await subscription.cancel();

    // Wait to confirm no more retries happen after cancel
    await Future<void>.delayed(const Duration(milliseconds: 30));

    // EXPECT - no further calls after cancel
    expect(callCount, equals(countAtCancel));
  });
}

RuIndicationMatchesResponseDto _matchesResponseDto() {
  return RuIndicationMatchesResponseDto(
    data: [
      RuIndicationLocationDto(
        tafTapLocationReference: 'CH003001',
        ruIndicationContents: [
          RuIndicationContentDto(
            title: 'Title A',
            text: 'Text A',
          ),
          RuIndicationContentDto(
            title: 'Title B',
            text: 'Text B',
          ),
        ],
      ),
      RuIndicationLocationDto(
        tafTapLocationReference: 'CH003002',
        ruIndicationContents: [
          RuIndicationContentDto(
            title: 'Title C',
            text: 'Text C',
          ),
        ],
      ),
    ],
  );
}

List<RuIndication> _expectedDomainResult() {
  return const [
    RuIndication(
      order: 1000,
      title: 'Title A',
      text: 'Text A',
    ),
    RuIndication(
      order: 1000,
      title: 'Title B',
      text: 'Text B',
    ),
    RuIndication(
      order: 2000,
      title: 'Title C',
      text: 'Text C',
    ),
  ];
}

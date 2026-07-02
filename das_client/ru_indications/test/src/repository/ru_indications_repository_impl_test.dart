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

  const company = 'SBB';
  const trainNumber = 12345;
  final startDate = DateTime(2026, 1, 15, 10);
  const Map<String, int> locationReferences = {
    'CH003001': 1000,
    'CH003002': 2000,
  };

  setUp(() {
    mockRuIndicationsApiService = MockRuIndicationsApiService();
    mockMatchesRequest = MockMatchesRequest();
    when(mockRuIndicationsApiService.matches).thenReturn(mockMatchesRequest);
    testee = RuIndicationsRepositoryImpl(apiService: mockRuIndicationsApiService);
  });

  test('fetchRuIndications_whenApiCallSucceeds_thenReturnsMappedDomainModels', () async {
    // ARRANGE
    when(
      mockMatchesRequest.call(
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenAnswer((_) async => MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto()));

    // ACT
    final result = await testee.fetchRuIndications(
      company: company,
      trainNumber: trainNumber.toString(),
      startDate: startDate,
      locationReferences: locationReferences,
    );

    // EXPECT
    expect(result, equals(_expectedDomainResult()));
  });

  test('fetchRuIndications_whenApiCallThrows_thenReturnsEmptyList', () async {
    // ARRANGE
    when(
      mockMatchesRequest.call(
        company: company,
        operationalTrainNumber: trainNumber,
        startDate: startDate,
        tafTapLocationReferences: locationReferences.keys.toList(),
      ),
    ).thenThrow(Exception('Failed'));

    // ACT
    final result = await testee.fetchRuIndications(
      company: company,
      trainNumber: trainNumber.toString(),
      startDate: startDate,
      locationReferences: locationReferences,
    );

    // EXPECT
    expect(result, isEmpty);
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

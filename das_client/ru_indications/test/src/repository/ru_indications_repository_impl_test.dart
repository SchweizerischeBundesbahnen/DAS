import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ru_indications/src/api/dto/ru_indication_content_dto.dart';
import 'package:ru_indications/src/api/dto/ru_indication_location_dto.dart';
import 'package:ru_indications/src/api/dto/ru_indication_matches_response_dto.dart';
import 'package:ru_indications/src/api/matches/matches_request.dart';
import 'package:ru_indications/src/api/ru_indications_api_service.dart';
import 'package:ru_indications/src/model/ru_indication.dart';
import 'package:ru_indications/src/model/ru_indication_content.dart';
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
  final startDate = DateTime(2026, 1, 15, 10, 0);
  const tafTapLocationReferences = <String>['8503000', '8507000'];

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
        tafTapLocationReferences: tafTapLocationReferences,
      ),
    ).thenAnswer((_) async => MatchesResponse(headers: <String, String>{}, body: _matchesResponseDto()));

    // ACT
    final result = await testee.fetchRuIndications(
      company: company,
      trainNumber: trainNumber,
      startDate: startDate,
      tafTapLocationReferences: tafTapLocationReferences,
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
        tafTapLocationReferences: tafTapLocationReferences,
      ),
    ).thenThrow(Exception('Failed'));

    // ACT
    final result = await testee.fetchRuIndications(
      company: company,
      trainNumber: trainNumber,
      startDate: startDate,
      tafTapLocationReferences: tafTapLocationReferences,
    );

    // EXPECT
    expect(result, isEmpty);
  });
}

RuIndicationMatchesResponseDto _matchesResponseDto() {
  return RuIndicationMatchesResponseDto(
    data: [
      RuIndicationLocationDto(
        tafTapLocationReference: '8503000',
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
        tafTapLocationReference: '8507000',
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
      tafTapLocationReference: '8503000',
      ruIndicationContents: [
        RuIndicationContent(
          title: 'Title A',
          text: 'Text A',
        ),
        RuIndicationContent(
          title: 'Title B',
          text: 'Text B',
        ),
      ],
    ),
    RuIndication(
      tafTapLocationReference: '8507000',
      ruIndicationContents: [
        RuIndicationContent(
          title: 'Title C',
          text: 'Text C',
        ),
      ],
    ),
  ];
}

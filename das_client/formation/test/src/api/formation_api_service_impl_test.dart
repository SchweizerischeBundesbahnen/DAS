import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:formation/src/api/dto/formation_dto.dart';
import 'package:formation/src/api/dto/formation_response_dto.dart';
import 'package:formation/src/api/formation_api_service.dart';
import 'package:formation/src/api/formation_api_service_impl.dart';
import 'package:http_x/component.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formation_api_service_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<Client>(),
])
void main() {
  final baseUrl = 'api.example.com';
  late FormationApiService testee;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();

    testee = FormationApiServiceImpl(
      baseUrl: baseUrl,
      httpClient: mockHttpClient,
    );
  });

  test('formation_when404NotFound_thenReturnNullResponse', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.value(Response('', HttpStatus.notFound)));

    // ACT
    final result = await testee.formation(operationalTrainNumber, company, operationalDay, null).call();

    // VERIFY
    expect(result.body, isNull);
  });

  test('formation_whenOk_thenReturnFormationResponseDto', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();
    final formationReponseDto = FormationResponseDto(
      data: [
        FormationDto(
          operationalTrainNumber: operationalTrainNumber,
          company: company,
          operationalDay: operationalDay,
          formationRuns: [],
        ),
      ],
    );

    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.value(Response(jsonEncode(formationReponseDto), HttpStatus.ok)));

    // ACT
    final result = await testee.formation(operationalTrainNumber, company, operationalDay, null).call();

    // VERIFY
    expect(result.body, isNotNull);
    expect(result.body, formationReponseDto);
  });

  test('formation_whenNotOk_thenThrowHttpException', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();

    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer((_) => Future.value(Response('', HttpStatus.badRequest, request: Request('get', Uri.parse(baseUrl)))));

    // ACT & VERIFY
    expect(
      () async => await testee.formation(operationalTrainNumber, company, operationalDay, null).call(),
      throwsA(isA<HttpException>()),
    );
  });

  test('formation_whenEtagIsGiven_thenAddsIfNoneMatchHeader', () async {
    // GIVEN
    final operationalTrainNumber = 'T1234';
    final company = '1285';
    final operationalDay = DateTime.now();
    final etag = 'ABCD1234';

    when(
      mockHttpClient.get(any, headers: anyNamed('headers')),
    ).thenAnswer(
      (_) => Future.value(
        Response('', HttpStatus.notModified, headers: {'etag': etag}, request: Request('get', Uri.parse(baseUrl))),
      ),
    );

    final result = await testee.formation(operationalTrainNumber, company, operationalDay, etag).call();

    // VERIFY
    expect(result.etag, etag);
    final captured = verify(
      mockHttpClient.get(captureAny, headers: captureAnyNamed('headers')),
    ).captured;
    final headers = captured[1] as Map<String, String>;
    expect(headers['If-None-Match'], etag);
  });
}

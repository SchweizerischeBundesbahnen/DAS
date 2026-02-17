import 'dart:convert';

import 'package:app_links_x/src/app_link_version.dart';
import 'package:app_links_x/src/train_journey/train_journey_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseV1_whenAllValuesProvided_returnsResult', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
          'company': '1285',
          'startDate': '2026-01-31',
          'tafTapLocationReferenceStart': 'CH04128',
          'tafTapLocationReferenceEnd': 'CH07000',
        },
        {
          'operationalTrainNumber': '987654321',
          'company': '2185',
          'startDate': '2026-02-15',
          'tafTapLocationReferenceStart': 'CH00218',
          'tafTapLocationReferenceEnd': 'CH03000',
        },
      ],
      'returnUrl': 'https://www.sbb.ch',
    };

    // WHEN
    final result = TrainJourneyParser.parse(_uri(dataJson: data), version: AppLinkVersion.v1);

    // THEN
    expect(result, hasLength(2));

    final journey1 = result[0];
    expect(journey1.operationalTrainNumber, '123456789');
    expect(journey1.company, '1285');
    expect(journey1.startDate, DateTime.parse('2026-01-31'));
    expect(journey1.tafTapLocationReferenceStart, 'CH04128');
    expect(journey1.tafTapLocationReferenceEnd, 'CH07000');

    final journey2 = result[1];
    expect(journey2.operationalTrainNumber, '987654321');
    expect(journey2.company, '2185');
    expect(journey2.startDate, DateTime.parse('2026-02-15'));
    expect(journey2.tafTapLocationReferenceStart, 'CH00218');
    expect(journey2.tafTapLocationReferenceEnd, 'CH03000');
  });

  test('parseV1_whenOnlyMandatoryValuesProvided_returnsResult', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
        },
      ],
    };

    // WHEN
    final result = TrainJourneyParser.parse(_uri(dataJson: data), version: AppLinkVersion.v1);

    // THEN
    expect(result, hasLength(1));
    final parsed = result.first;
    expect(parsed.operationalTrainNumber, '123456789');
    expect(parsed.company, isNull);
    expect(parsed.startDate, isNull);
    expect(parsed.tafTapLocationReferenceStart, isNull);
    expect(parsed.tafTapLocationReferenceEnd, isNull);
  });

  test('parseV1_whenDataParameterNotLowerCase_returnsResult', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
          'company': '1285',
        },
      ],
    };
    final queryParams = {'DATA': jsonEncode(data)};

    // WHEN
    final result = TrainJourneyParser.parse(_uri(queryParams: queryParams), version: AppLinkVersion.v1);

    // THEN
    expect(result, hasLength(1));
    final parsed = result.first;
    expect(parsed.operationalTrainNumber, '123456789');
    expect(parsed.company, '1285');
  });

  test('parseV1_whenNoDataParam_throwsFormatException', () {
    // GIVEN
    final uri = _uri();

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri, version: AppLinkVersion.v1), throwsFormatException);
  });

  test('parseV1_whenEmptyDataParam_throwsFormatException', () {
    // GIVEN
    final queryParams = {'data': ''};
    final uri = _uri(queryParams: queryParams);

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri, version: AppLinkVersion.v1), throwsFormatException);
  });

  test('parseV1_whenNoJsonDataParam_throwsFormatException', () {
    // GIVEN
    final queryParams = {'data': 'not a json'};
    final uri = _uri(queryParams: queryParams);

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri, version: AppLinkVersion.v1), throwsFormatException);
  });

  test('parse_whenUnsupportedVersion_throwsUnimplementedError', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
          'company': '1285',
        },
      ],
    };
    final queryParams = {'DATA': jsonEncode(data)};

    // WHEN THEN
    expect(
      () => TrainJourneyParser.parse(_uri(queryParams: queryParams), version: AppLinkVersion.unknown),
      throwsUnimplementedError,
    );
  });
}

Uri _uri({Map<String, dynamic>? dataJson, Map<String, dynamic>? queryParams}) {
  final params = queryParams ?? (dataJson != null ? {'data': jsonEncode(dataJson)} : null);
  return Uri(
    scheme: 'https',
    host: 'driveradvisorysystem.app.sbb.ch',
    path: 'dev/v1/${TrainJourneyParser.page}',
    queryParameters: params,
  );
}

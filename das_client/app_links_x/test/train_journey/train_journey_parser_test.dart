import 'dart:convert';

import 'package:app_links_x/src/train_journey/train_journey_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Uri with all values can be parsed', () {
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
    final result = TrainJourneyParser.parse(_uri(dataJson: data));

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

  test('Uri with only mandatory values can be parsed', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
        },
      ],
    };

    // WHEN
    final result = TrainJourneyParser.parse(_uri(dataJson: data));

    // THEN
    expect(result, hasLength(1));
    final parsed = result.first;
    expect(parsed.operationalTrainNumber, '123456789');
    expect(parsed.company, isNull);
    expect(parsed.startDate, isNull);
    expect(parsed.tafTapLocationReferenceStart, isNull);
    expect(parsed.tafTapLocationReferenceEnd, isNull);
  });

  test('Uri can be parsed even if data parameter is not written in lower-case', () {
    // GIVEN
    final data = {
      'journeys': [
        {
          'operationalTrainNumber': '123456789',
          'company': '1285',
        },
      ],
    };

    // WHEN
    final queryParams = {'DATA': jsonEncode(data)};
    final result = TrainJourneyParser.parse(_uri(queryParams: queryParams));

    // THEN
    expect(result, hasLength(1));
    final parsed = result.first;
    expect(parsed.operationalTrainNumber, '123456789');
    expect(parsed.company, '1285');
  });

  test('throws when data param is missing', () {
    // GIVEN
    final uri = _uri();

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri), throwsFormatException);
  });

  test('throws when data param is empty', () {
    // GIVEN
    final queryParams = {'data': ''};
    final uri = _uri(queryParams: queryParams);

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri), throwsFormatException);
  });

  test('throws when data is not valid JSON', () {
    // GIVEN
    final queryParams = {'data': 'not a json'};
    final uri = _uri(queryParams: queryParams);

    // WHEN THEN
    expect(() => TrainJourneyParser.parse(uri), throwsFormatException);
  });
}

Uri _uri({Map<String, dynamic>? dataJson, Map<String, dynamic>? queryParams}) {
  final params = queryParams ?? (dataJson != null ? {'data': jsonEncode(dataJson)} : null);
  return Uri(
    scheme: 'https',
    host: 'driveradvisorysystem.sbb.ch',
    path: 'dev/v1/${TrainJourneyParser.page}',
    queryParameters: params,
  );
}

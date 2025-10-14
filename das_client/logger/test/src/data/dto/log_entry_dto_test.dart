import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/src/data/dto/splunk_log_entry_dto.dart';
import 'package:logger/src/log_level.dart';

void main() {
  late SplunkLogEntryDto testee;

  setUp(() {
    testee = SplunkLogEntryDto(
      time: 1624046400.0,
      event: 'A test log message',
      level: LogLevel.info.name,
      fields: {'key1': 'value1', 'key2': 2},
    );
  });

  test('returns compact JSON string by default', () {
    // arrange
    const expectedEncodedString =
        '{"time":1624046400.0,"source":"das-client","event":"A test log message","fields":{"key1":"value1","key2":2,"level":"info"}}';

    // act
    final actual = testee.toJsonString();

    // expect
    expect(actual, equals(expectedEncodedString));
  });

  test('returns pretty printed JSON string when pretty is true', () {
    // arrange
    final expectedDecodedMap = {
      'time': 1624046400.0,
      'source': 'das-client',
      'event': 'A test log message',
      'fields': {'key1': 'value1', 'key2': 2, 'level': 'info'},
    };

    final prettyEncoder = JsonEncoder.withIndent(SplunkLogEntryDto.jsonIndent);
    final expectedPrettyString = prettyEncoder.convert(expectedDecodedMap);

    // Act: Get JSON string with pretty printing.
    final actual = testee.toJsonString(pretty: true);

    // Assert: Decode both JSON strings and compare maps.
    final decodedJson = json.decode(actual);
    expect(decodedJson, equals(expectedDecodedMap));

    // You can also check for proper formatting if desired.
    expect(actual, equals(expectedPrettyString));
  });
}

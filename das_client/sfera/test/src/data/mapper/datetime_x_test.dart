import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/data/mapper/datetime_x.dart';
import 'package:sfera/src/model/journey/communication_network_change.dart';

main() {
  test('parseNullable_whenNull_returnsNull', () {
    // WHEN & THEN
    expect(DateTimeX.parseNullable(null), isNull);
  });

  test('parseNullable_whenNonNullAndWellFormed_returnsCorrectDateTime', () {
    // GIVEN
    final firstSteamTrain = '1825-09-27T00:00:00Z';

    // WHEN
    final actual = DateTimeX.parseNullable(firstSteamTrain);

    // THEN
    expect(actual, DateTime.parse(firstSteamTrain));
  });

  test('parseNullable_whenInvalidDateTime_throws', () {
    // WHEN & Then
    expect(() => DateTimeX.parseNullable('invalid'), throwsA(isA<FormatException>()));
  });
}

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('test ASR is displayed outside of ETCS level 2 segments', () {
    // GIVEN
    final indication = UncodedOperationalIndication(order: 100, texts: ['Text A', 'Text B']);

    // WHEN
    final combinedText = indication.combinedText;

    // THEN
    expect(combinedText, 'Text A\nText B');
  });

  test('test ASR is displayed outside of ETCS level 2 segments', () {
    // GIVEN
    final sameLocationA = UncodedOperationalIndication(order: 100, texts: ['Text A']);
    final sameLocationB = UncodedOperationalIndication(order: 100, texts: ['Text B']);
    final otherLocation = UncodedOperationalIndication(order: 200, texts: ['Text C']);
    final indications = [sameLocationA, sameLocationB, otherLocation];

    // WHEN
    final mergedIndications = indications.mergeOnSameLocation().toList();
    mergedIndications.sortedBy((i) => i.order);

    // THEN
    expect(mergedIndications, hasLength(2));
    expect(mergedIndications[0].order, 100);
    expect(mergedIndications[0].texts, hasLength(2));
    expect(mergedIndications[0].texts, contains('Text A'));
    expect(mergedIndications[0].texts, contains('Text B'));
    expect(mergedIndications[1].order, 200);
    expect(mergedIndications[1].texts, hasLength(1));
    expect(mergedIndications[1].texts[0], 'Text C');
  });
}

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('test texts of OperationalIndication are combined correctly', () {
    // GIVEN
    final indication = OperationalIndication(order: 100, texts: ['Text A', 'Text B']);

    // WHEN
    final combinedText = indication.combinedText;

    // THEN
    expect(combinedText, 'Text A\nText B');
  });

  test('test OperationalIndication on same location are merged', () {
    // GIVEN
    final sameLocationA = OperationalIndication(order: 100, texts: ['Text A']);
    final sameLocationB = OperationalIndication(order: 100, texts: ['Text B']);
    final otherLocation = OperationalIndication(order: 200, texts: ['Text C']);
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

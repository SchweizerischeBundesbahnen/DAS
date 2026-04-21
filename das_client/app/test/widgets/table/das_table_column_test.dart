import 'package:app/widgets/table/das_table_column.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late Iterable<DASTableColumn> columns;

  setUp(() {
    initializeDateFormatting();
    columns = [
      DASTableColumn(id: 1, width: 100.0),
      DASTableColumn(id: 2, width: 200.0),
      DASTableColumn(id: null, width: 50.0),
      DASTableColumn(id: 3, width: 300.0),
      DASTableColumn(id: 4, width: 400.0),
    ];
  });

  test('leftOffsetTo_whenCalledWithFirstIndex_thenReturnsZero', () {
    // WHEN
    final leftOffset = columns.leftOffsetTo(columnId: 1);

    // THEN
    expect(leftOffset, 0);
  });

  test('leftOffsetTo_whenCalledWithSecondIndex_thenReturnsWidthOfFirst', () {
    // WHEN
    final leftOffset = columns.leftOffsetTo(columnId: 2);

    // THEN
    expect(leftOffset, 100);
  });

  test('leftOffsetTo_whenCalledWithIndexAfterNullIndex_thenReturnsOffsetIncludingNull', () {
    // WHEN
    final leftOffset = columns.leftOffsetTo(columnId: 3);

    // THEN
    expect(leftOffset, 350);
  });

  test('leftOffsetTo_whenCalledWithUnknownIndex_thenReturnsZero', () {
    // WHEN
    final leftOffset = columns.leftOffsetTo(columnId: 8);

    // THEN
    expect(leftOffset, 0);
  });
}

import 'package:app/pages/journey/journey_screen/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/signal_row.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';

import 'journey_table_scroll_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ScrollController>(),
  MockSpec<ScrollPosition>(),
  MockSpec<ServicePointRow>(),
  MockSpec<GlobalKey>(),
  MockSpec<BuildContext>(),
  MockSpec<RenderBox>(),
])
void main() {
  // The Flutter binding must be initialised because scrollToJourneyPoint uses
  // WidgetsBinding.instance.addPostFrameCallback internally.
  TestWidgetsFlutterBinding.ensureInitialized();

  late JourneyTableScrollController testee;

  // tableKey returns Offset(0, -40).  With headerRowHeight=40 this means
  // distanceFromTableTop = targetGlobalY − (−40) − 40 = targetGlobalY.
  // So a row whose mock key returns Offset(0, Y) contributes exactly Y to the
  // scroll target — which makes expected values easy to reason about.
  const double dasTableKeyGlobalY = -40;
  const double rowHeight = CellRowBuilder.rowHeight; // 44
  const double spHeight = ServicePointRow.baseRowHeight; // 64

  final List<JourneyPoint> journeyData = [
    Signal(order: 0, kilometre: []),
    Signal(order: 100, kilometre: []),
    Signal(order: 200, kilometre: []),
    Signal(order: 300, kilometre: []),
    Signal(order: 400, kilometre: []),
  ];

  // Each row sits at its natural position: row i starts at i * rowHeight.
  final renderedRows = journeyData
      .mapIndexed(
        (index, data) => mockSignalRow(data as Signal, Offset(0, index * rowHeight), index),
      )
      .toList();

  late MockScrollController mockScrollController;
  late MockScrollPosition mockScrollPosition;

  setUp(() {
    mockScrollController = MockScrollController();
    mockScrollPosition = MockScrollPosition();
    when(mockScrollController.positions).thenReturn([mockScrollPosition]);
    when(mockScrollController.position).thenReturn(mockScrollPosition);
    when(mockScrollPosition.pixels).thenReturn(0.0);
    when(mockScrollPosition.maxScrollExtent).thenReturn(rowHeight * 4);
    testee = JourneyTableScrollController(
      controller: mockScrollController,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableKeyGlobalY)),
    );
    testee.updateRenderedRows(renderedRows);
  });

  testWidgets('scrollToJourneyPoint_whenEmptyRenderedRows_thenDoesNothing', (tester) async {
    // ARRANGE
    testee.updateRenderedRows([]);

    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);
    await _flushPostFrameCallback(tester); // flush postFrameCallback

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  testWidgets('scrollToJourneyPoint_whenNotAttachedToScrollView_thenDoesNothing', (tester) async {
    // ARRANGE
    when(mockScrollController.positions).thenReturn([]);

    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);
    await _flushPostFrameCallback(tester);

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
    verifyNever(mockScrollController.position);
  });

  testWidgets('scrollToJourneyPoint_whenTargetNotInRenderedRows_thenDoesNothing', (tester) async {
    // ARRANGE
    final target = Signal(order: 200_000, kilometre: []);

    // ACT
    testee.scrollToJourneyPoint(target);
    await _flushPostFrameCallback(tester);

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
    verifyNever(mockScrollController.position);
  });

  testWidgets('scrollToJourneyPoint_whenCalledWithThirdPoint_thenScrollsToCorrectElementOffset', (tester) async {
    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);
    await _flushPostFrameCallback(tester);

    // EXPECT
    // journeyData[2] is at global Y = 2 * rowHeight = 88.
    // distanceFromListTop = 88 − (−40) − 40 = 88.
    // stickyHeight = 0. target = 0 + 88 − 0 = 88 = rowHeight * 2.
    verify(
      mockScrollController.animateTo(
        rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  testWidgets('scrollToJourneyPoint_whenHasStickyHeaderAndTargetInFirstBlock_thenScrollsToCorrectElementOffset', (
    tester,
  ) async {
    // ARRANGE
    final signal = Signal(order: 100, kilometre: []);
    final targetSignal = Signal(order: 300, kilometre: []);
    final servicePoint = ServicePoint(order: 0, abbreviation: '', locationCode: '', kilometre: [], name: '');

    // Layout (cumulative Y from top of list content, i.e. globalY = listY):
    //   0: servicePoint  Y=0,       height=64
    //   1: signal        Y=64,      height=44
    //   2: targetSignal  Y=108,     height=44  ← target
    //   3: signal        Y=152,     height=44
    //   4: servicePoint  Y=196,     height=64
    //   5: signal        Y=260,     height=44
    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePoint, Offset(0, 0), spHeight),
      mockSignalRow(signal, Offset(0, spHeight), 1),
      mockSignalRow(targetSignal, Offset(0, spHeight + rowHeight), 2),
      mockSignalRow(signal, Offset(0, spHeight + rowHeight * 2), 3),
      mockServicePointRow(servicePoint, Offset(0, spHeight + rowHeight * 3), spHeight),
      mockSignalRow(signal, Offset(0, spHeight * 2 + rowHeight * 3), 5),
    ];

    when(mockScrollPosition.maxScrollExtent).thenReturn(rowHeight * 10);
    testee.updateRenderedRows(rows);

    // ACT
    testee.scrollToJourneyPoint(targetSignal);
    await _flushPostFrameCallback(tester);

    // EXPECT
    // targetSignal global Y = spHeight + rowHeight = 64 + 44 = 108.
    // distanceFromListTop = 108 − (−40) − 40 = 108.
    // stickyHeight: servicePoint[0] is first sticky → stickyHeaderHeights[first] = spHeight = 64.
    //              targetSignal reached → returns 64.
    // target = 0 + 108 − 64 = 44 = rowHeight.
    verify(
      mockScrollController.animateTo(
        rowHeight,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  testWidgets('scrollToJourneyPoint_whenHasStickyHeaderAndTargetInSecondBlock_thenScrollsToCorrectElementOffset', (
    tester,
  ) async {
    // ARRANGE
    final signal = Signal(order: 100, kilometre: []);
    final targetSignal = Signal(order: 300, kilometre: []);
    final servicePoint = ServicePoint(order: 0, abbreviation: '', locationCode: '', kilometre: [], name: '');

    // Layout:
    //   0: servicePoint  Y=0,       height=64
    //   1: signal        Y=64,      height=44
    //   2: signal        Y=108,     height=44
    //   3: signal        Y=152,     height=44
    //   4: servicePoint  Y=196,     height=64
    //   5: targetSignal  Y=260,     height=44  ← target
    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePoint, Offset(0, 0), spHeight),
      mockSignalRow(signal, Offset(0, spHeight), 1),
      mockSignalRow(signal, Offset(0, spHeight + rowHeight), 2),
      mockSignalRow(signal, Offset(0, spHeight + rowHeight * 2), 3),
      mockServicePointRow(servicePoint, Offset(0, spHeight + rowHeight * 3), spHeight),
      mockSignalRow(targetSignal, Offset(0, spHeight * 2 + rowHeight * 3), 5),
    ];

    when(mockScrollPosition.maxScrollExtent).thenReturn(rowHeight * 10);
    testee.updateRenderedRows(rows);

    // ACT
    testee.scrollToJourneyPoint(targetSignal);
    await _flushPostFrameCallback(tester);

    // EXPECT
    // targetSignal global Y = spHeight*2 + rowHeight*3 = 128 + 132 = 260.
    // distanceFromListTop = 260 − (−40) − 40 = 260.
    // stickyHeight: servicePoint[0] → first=64; servicePoint[4] → first=64 (reset second).
    //              targetSignal reached → returns 64.
    // target = 0 + 260 − 64 = 196 = rowHeight*3 + spHeight.
    verify(
      mockScrollController.animateTo(
        rowHeight * 3 + spHeight,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });
}

Future<void> _flushPostFrameCallback(WidgetTester tester) async {
  tester.binding.scheduleFrame();
  await tester.pump();
}

SignalRow mockSignalRow(Signal data, Offset offset, int rowIndex) {
  return SignalRow(
    metadata: Metadata(),
    data: data,
    rowIndex: rowIndex,
    journeyPosition: JourneyPositionModel(),
    key: mockGlobalKeyOffset(offset),
  );
}

ServicePointRow mockServicePointRow(ServicePoint data, Offset offset, double height) {
  final servicePointRow = MockServicePointRow();
  final mockKey = mockGlobalKeyOffset(offset, height: height);
  when(servicePointRow.data).thenReturn(data);
  when(servicePointRow.height).thenReturn(height);
  when(servicePointRow.stickyLevel).thenReturn(.first);
  when(servicePointRow.key).thenReturn(mockKey);
  return servicePointRow;
}

GlobalKey mockGlobalKeyOffset(Offset offset, {double height = 0.0}) {
  final mockDasTableKey = MockGlobalKey();
  final mockDasTableContext = MockBuildContext();
  final mockRenderBox = MockRenderBox();
  when(mockDasTableKey.currentContext).thenReturn(mockDasTableContext);
  when(mockDasTableContext.findRenderObject()).thenReturn(mockRenderBox);
  when(mockRenderBox.localToGlobal(any)).thenReturn(offset);
  when(mockRenderBox.size).thenReturn(Size(0, height));
  return mockDasTableKey;
}

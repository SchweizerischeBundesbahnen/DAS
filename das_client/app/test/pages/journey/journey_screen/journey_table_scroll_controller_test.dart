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
  late JourneyTableScrollController testee;
  const double dasTableHeaderOffset = -40;
  final List<JourneyPoint> journeyData = [
    Signal(order: 0, kilometre: []),
    Signal(order: 100, kilometre: []),
    Signal(order: 200, kilometre: []),
    Signal(order: 300, kilometre: []),
    Signal(order: 400, kilometre: []),
  ];
  final renderedRows = journeyData
      .mapIndexed(
        (index, data) => SignalRow(
          metadata: Metadata(),
          data: data as Signal,
          rowIndex: index,
          journeyPosition: JourneyPositionModel(),
          key: mockGlobalKeyOffset(Offset(0, 0)),
        ),
      )
      .toList();

  late MockScrollController mockScrollController;
  late MockScrollPosition mockScrollPosition;

  setUp(() {
    mockScrollController = MockScrollController();
    mockScrollPosition = MockScrollPosition();
    when(mockScrollController.positions).thenReturn([mockScrollPosition]);
    when(mockScrollController.position).thenReturn(mockScrollPosition);
    when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
    testee = JourneyTableScrollController(
      controller: mockScrollController,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );
    testee.updateRenderedRows(renderedRows);
  });

  test('scrollToJourneyPoint_whenEmptyRenderedRows_thenDoesNothing', () {
    // ARRANGE
    testee.updateRenderedRows([]);

    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('scrollToJourneyPoint_whenNotAttachedToScrollView_thenDoesNothing', () {
    // ARRANGE
    when(mockScrollController.positions).thenReturn([]);

    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
    verifyNever(mockScrollController.position);
  });

  test('scrollToJourneyPoint_whenTargetNotInRenderedRows_thenDoesNothing', () {
    // ARRANGE
    final target = Signal(order: 200_000, kilometre: []);

    // ACT
    testee.scrollToJourneyPoint(target);

    // EXPECT
    verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
    verifyNever(mockScrollController.position);
  });

  test('scrollToJourneyPoint_whenCalledWithThirdPoint_thenScrollsToCorrectElementOffset', () {
    // ACT
    testee.scrollToJourneyPoint(journeyData[2]);

    // EXPECT
    verify(
      mockScrollController.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  test('scrollToJourneyPoint_whenHasStickyHeaderAndTargetInFirstBlock_thenScrollsToCorrectElementOffset', () {
    // ARRANGE
    final signal = Signal(order: 100, kilometre: []);
    final targetSignal = Signal(order: 300, kilometre: []);
    final servicePoint = ServicePoint(order: 0, abbreviation: '', locationCode: '', kilometre: [], name: '');

    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePoint, Offset(0, 0)),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 1),
      SignalRow(metadata: Metadata(), data: targetSignal, journeyPosition: JourneyPositionModel(), rowIndex: 2),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 3),
      mockServicePointRow(servicePoint, Offset(0, 196)),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 5),
    ];

    when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 10);

    testee.updateRenderedRows(rows);

    // ACT
    testee.scrollToJourneyPoint(targetSignal);

    // EXPECT
    verify(
      mockScrollController.animateTo(
        CellRowBuilder.rowHeight,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  test('scrollToJourneyPoint_whenHasStickyHeaderAndTargetInSecondBlock_thenScrollsToCorrectElementOffset', () {
    // ARRANGE
    final signal = Signal(order: 100, kilometre: []);
    final targetSignal = Signal(order: 300, kilometre: []);
    final servicePoint = ServicePoint(order: 0, abbreviation: '', locationCode: '', kilometre: [], name: '');

    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePoint, Offset(0, 0)),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 1),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 2),
      SignalRow(metadata: Metadata(), data: signal, journeyPosition: JourneyPositionModel(), rowIndex: 3),
      mockServicePointRow(servicePoint, Offset(0, 196)),
      SignalRow(metadata: Metadata(), data: targetSignal, journeyPosition: JourneyPositionModel(), rowIndex: 5),
    ];

    when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 10);

    testee.updateRenderedRows(rows);

    // ACT
    testee.scrollToJourneyPoint(targetSignal);

    // EXPECT
    verify(
      mockScrollController.animateTo(
        CellRowBuilder.rowHeight * 3 + ServicePointRow.baseRowHeight,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });
}

ServicePointRow mockServicePointRow(ServicePoint data, Offset offset) {
  final servicePointRow = MockServicePointRow();
  final mockKey = mockGlobalKeyOffset(offset);
  when(servicePointRow.data).thenReturn(data);
  when(servicePointRow.height).thenReturn(ServicePointRow.baseRowHeight);
  when(servicePointRow.stickyLevel).thenReturn(.first);
  when(servicePointRow.key).thenReturn(mockKey);
  return servicePointRow;
}

GlobalKey mockGlobalKeyOffset(Offset offset) {
  final mockDasTableKey = MockGlobalKey();
  final mockDasTableContext = MockBuildContext();
  final mockRenderBox = MockRenderBox();
  when(mockDasTableKey.currentContext).thenReturn(mockDasTableContext);
  when(mockDasTableContext.findRenderObject()).thenReturn(mockRenderBox);
  when(mockRenderBox.localToGlobal(any)).thenReturn(offset);
  return mockDasTableKey;
}

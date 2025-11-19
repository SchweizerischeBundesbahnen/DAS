import 'package:app/pages/journey/journey_table/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/journey_table/journey_table_scroll_controller.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_table/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/signal_row.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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
    GetIt.I.registerSingleton(TimeConstants());
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

  tearDown(() {
    GetIt.I.reset();
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
    final servicePoint = ServicePoint(order: 0, kilometre: [], name: '');

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
    final servicePoint = ServicePoint(order: 0, abbreviation: '', kilometre: [], name: '');

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
  //
  // test('test does not scroll to correct element offset if not active', () {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[2] as JourneyPoint;
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: false);
  //
  //   verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  // });
  //
  // test('test only scroll if position is different then the last update', () {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[2] as JourneyPoint;
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //   when(mockScrollController.positions).thenReturn([mockScrollPosition]);
  //   when(mockScrollController.position).thenReturn(mockScrollPosition);
  //   when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);
  //   testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);
  //
  //   verify(
  //     mockScrollController.animateTo(
  //       CellRowBuilder.rowHeight * 2,
  //       duration: anyNamed('duration'),
  //       curve: anyNamed('curve'),
  //     ),
  //   ).called(1);
  // });
  //
  // test('test does not scroll and is not active if currentPosition is same as routeStart', () {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[0] as JourneyPoint;
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //   when(mockScrollController.positions).thenReturn([mockScrollPosition]);
  //   when(mockScrollController.position).thenReturn(mockScrollPosition);
  //   when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(
  //     currentPosition: currentPosition,
  //     routeStart: journeyData[0] as JourneyPoint,
  //     isAdvancementEnabledByUser: true,
  //   );
  //
  //   expect(testee.isActive, false);
  //   verifyNever(
  //     mockScrollController.animateTo(
  //       CellRowBuilder.rowHeight * 2,
  //       duration: anyNamed('duration'),
  //       curve: anyNamed('curve'),
  //     ),
  //   );
  // });
  //
  //

  //
  // test('test scrolls with delay after touch', () async {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[2] as JourneyPoint;
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //   when(mockScrollController.positions).thenReturn([mockScrollPosition]);
  //   when(mockScrollController.position).thenReturn(mockScrollPosition);
  //   when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);
  //
  //   FakeAsync().run((fakeAsync) {
  //     testee.resetScrollTimer();
  //
  //     fakeAsync.elapse(const Duration(seconds: 11));
  //   });
  //
  //   verify(
  //     mockScrollController.animateTo(
  //       CellRowBuilder.rowHeight * 2,
  //       duration: anyNamed('duration'),
  //       curve: anyNamed('curve'),
  //     ),
  //   ).called(2);
  // });
  //
  // test('test does not scroll with delay after touch if disabled', () async {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[2] as JourneyPoint;
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //   when(mockScrollController.positions).thenReturn([mockScrollPosition]);
  //   when(mockScrollController.position).thenReturn(mockScrollPosition);
  //   when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);
  //
  //   verify(
  //     mockScrollController.animateTo(
  //       CellRowBuilder.rowHeight * 2,
  //       duration: anyNamed('duration'),
  //       curve: anyNamed('curve'),
  //     ),
  //   ).called(1);
  //
  //   FakeAsync().run((fakeAsync) {
  //     testee.resetScrollTimer();
  //
  //     testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: false);
  //
  //     fakeAsync.elapse(const Duration(seconds: 11));
  //   });
  //
  //   verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  // });
  //
  // test('test does not scroll when before first service point', () async {
  //   final List<BaseData> journeyData = [
  //     Signal(order: 0, kilometre: []),
  //     Signal(order: 100, kilometre: []),
  //     Signal(order: 200, kilometre: []),
  //     Signal(order: 300, kilometre: []),
  //     Signal(order: 400, kilometre: []),
  //   ];
  //
  //   final renderedRows = journeyData
  //       .mapIndexed(
  //         (index, data) => SignalRow(
  //           metadata: Metadata(),
  //           data: data as Signal,
  //           journeyPosition: JourneyPositionModel(),
  //           rowIndex: index,
  //           key: mockGlobalKeyOffset(Offset(0, 0)),
  //         ),
  //       )
  //       .toList();
  //   final currentPosition = journeyData[2] as JourneyPoint;
  //   final firstServicePoint = ServicePoint(order: 500, kilometre: [], name: ''); // after current position
  //
  //   final mockScrollController = MockScrollController();
  //   final mockScrollPosition = MockScrollPosition();
  //   when(mockScrollController.positions).thenReturn([mockScrollPosition]);
  //   when(mockScrollController.position).thenReturn(mockScrollPosition);
  //   when(mockScrollPosition.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);
  //
  //   final testee = JourneyTableScrollController(
  //     controller: mockScrollController,
  //     tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
  //   );
  //
  //   testee.updateRenderedRows(renderedRows);
  //   testee.handleJourneyUpdate(
  //     currentPosition: currentPosition,
  //     isAdvancementEnabledByUser: true,
  //     firstServicePoint: firstServicePoint,
  //   );
  //
  //   verifyNever(mockScrollController.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  // });
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

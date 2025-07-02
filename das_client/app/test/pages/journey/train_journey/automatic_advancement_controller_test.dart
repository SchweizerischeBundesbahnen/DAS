import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/metadata.dart';
import 'package:sfera/src/model/journey/service_point.dart';
import 'package:sfera/src/model/journey/signal.dart';

import 'automatic_advancement_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ScrollController>(),
  MockSpec<ScrollPosition>(),
  MockSpec<ServicePointRow>(),
  MockSpec<GlobalKey>(),
  MockSpec<BuildContext>(),
  MockSpec<RenderBox>(),
])
void main() {
  const double dasTableHeaderOffset = -40;

  test('test does nothing without anything provided', () {
    final scrollControllerMock = MockScrollController();
    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.scrollToCurrentPosition();

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('test scrolls to correct element offset', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];

    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);

    verify(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  test('test does not scroll to correct element offset if not active', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: false);

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('test only scroll if position is different then the last update', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);

    verify(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  test('test does not scroll and is not active if currentPosition is same as routeStart', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[0];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(
      currentPosition: currentPosition,
      routeStart: journeyData[0],
      isAdvancementEnabledByUser: true,
    );

    expect(testee.isActive, false);
    verifyNever(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    );
  });

  test('test does nothing if not attached to a scrollview', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData
        .mapIndexed((index, data) => SignalRow(metadata: Metadata(), data: data as Signal, rowIndex: index))
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('test scrolling adjust to sticky header', () {
    final signalData = Signal(order: 100, kilometre: []);
    final targetSignalData = Signal(order: 300, kilometre: []);
    final servicePointData = ServicePoint(order: 0, kilometre: [], name: '');

    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePointData, Offset(0, 0)),
      SignalRow(metadata: Metadata(), data: signalData, rowIndex: 1),
      SignalRow(metadata: Metadata(), data: signalData, rowIndex: 2),
      SignalRow(metadata: Metadata(), data: signalData, rowIndex: 3),
      mockServicePointRow(servicePointData, Offset(0, 196)),
      SignalRow(metadata: Metadata(), data: targetSignalData, rowIndex: 5),
    ];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 10);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(rows);
    testee.handleJourneyUpdate(currentPosition: targetSignalData, isAdvancementEnabledByUser: true);

    verify(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 3 + ServicePointRow.baseRowHeight,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);
  });

  test('test scrolls with delay after touch', () async {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];

    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);

    FakeAsync().run((fakeAsync) {
      testee.resetScrollTimer();

      fakeAsync.elapse(const Duration(seconds: 11));
    });

    verify(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(2);
  });

  test('test does not scroll with delay after touch if disabled', () async {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];

    final journeyRows = journeyData
        .mapIndexed(
          (index, data) => SignalRow(
            metadata: Metadata(),
            data: data as Signal,
            rowIndex: index,
            key: mockGlobalKeyOffset(Offset(0, 0)),
          ),
        )
        .toList();
    final currentPosition = journeyData[2];

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(
      controller: scrollControllerMock,
      tableKey: mockGlobalKeyOffset(Offset(0, dasTableHeaderOffset)),
    );

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: true);

    verify(
      scrollControllerMock.animateTo(
        CellRowBuilder.rowHeight * 2,
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ),
    ).called(1);

    FakeAsync().run((fakeAsync) {
      testee.resetScrollTimer();

      testee.handleJourneyUpdate(currentPosition: currentPosition, isAdvancementEnabledByUser: false);

      fakeAsync.elapse(const Duration(seconds: 11));
    });

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });
}

ServicePointRow mockServicePointRow(ServicePoint data, Offset offset) {
  final servicePointRow = MockServicePointRow();
  final mockKey = mockGlobalKeyOffset(offset);
  when(servicePointRow.data).thenReturn(data);
  when(servicePointRow.height).thenReturn(ServicePointRow.baseRowHeight);
  when(servicePointRow.stickyLevel).thenReturn(StickyLevel.first);
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

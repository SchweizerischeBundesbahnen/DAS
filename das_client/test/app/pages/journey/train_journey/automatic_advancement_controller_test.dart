import 'package:das_client/app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cell_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_level.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'automatic_advancement_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ScrollController>(),
  MockSpec<ScrollPosition>(),
  MockSpec<ServicePointRow>(),
])
void main() {
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
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));

    verify(scrollControllerMock.animateTo(CellRowBuilder.rowHeight * 2,
            duration: anyNamed('duration'), curve: anyNamed('curve')))
        .called(1);
  });

  test('test does not scroll to correct element offset if not active', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: false));

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('test only scroll if positon is different then the last update', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));

    verify(scrollControllerMock.animateTo(CellRowBuilder.rowHeight * 2,
            duration: anyNamed('duration'), curve: anyNamed('curve')))
        .called(1);
  });

  test('test does nothing if not attached to a scrollview', () {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  test('test scrolling adjust to sticky header', () {
    final signalData = Signal(order: 100, kilometre: []);
    final targetSignalData = Signal(order: 300, kilometre: []);
    final servicePointData = ServicePoint(order: 0, kilometre: [], name: '');

    final List<CellRowBuilder> rows = [
      mockServicePointRow(servicePointData),
      SignalRow(metadata: Metadata(), data: signalData),
      SignalRow(metadata: Metadata(), data: signalData),
      SignalRow(metadata: Metadata(), data: signalData),
      mockServicePointRow(servicePointData),
      SignalRow(metadata: Metadata(), data: targetSignalData),
    ];

    final journey = Journey(
      metadata: Metadata(currentPosition: targetSignalData),
      data: [],
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 10);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(rows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));

    verify(scrollControllerMock.animateTo(
      CellRowBuilder.rowHeight * 3 + ServicePointRow.rowHeight,
      duration: anyNamed('duration'),
      curve: anyNamed('curve'),
    )).called(1);
  });

  test('test scrolls with delay after touch', () async {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));
    testee.onTouch();

    await Future.delayed(const Duration(seconds: 11));

    verify(scrollControllerMock.animateTo(CellRowBuilder.rowHeight * 2,
            duration: anyNamed('duration'), curve: anyNamed('curve')))
        .called(2);
  });

  test('test does not scroll with delay after touch if disabled', () async {
    final List<BaseData> journeyData = [
      Signal(order: 0, kilometre: []),
      Signal(order: 100, kilometre: []),
      Signal(order: 200, kilometre: []),
      Signal(order: 300, kilometre: []),
      Signal(order: 400, kilometre: []),
    ];
    final journeyRows = journeyData.map((data) => SignalRow(metadata: Metadata(), data: data as Signal)).toList();
    final journey = Journey(
      metadata: Metadata(currentPosition: journeyData[2]),
      data: journeyData,
    );

    final scrollControllerMock = MockScrollController();
    final scrollPositionMock = MockScrollPosition();
    when(scrollControllerMock.positions).thenReturn([scrollPositionMock]);
    when(scrollControllerMock.position).thenReturn(scrollPositionMock);
    when(scrollPositionMock.maxScrollExtent).thenReturn(CellRowBuilder.rowHeight * 4);

    final testee = AutomaticAdvancementController(controller: scrollControllerMock);

    testee.updateRenderedRows(journeyRows);
    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: true));

    verify(scrollControllerMock.animateTo(CellRowBuilder.rowHeight * 2,
            duration: anyNamed('duration'), curve: anyNamed('curve')))
        .called(1);

    testee.onTouch();

    testee.handleJourneyUpdate(journey, TrainJourneySettings(automaticAdvancementActive: false));

    await Future.delayed(const Duration(seconds: 11));

    verifyNever(scrollControllerMock.animateTo(any, duration: anyNamed('duration'), curve: anyNamed('curve')));
  });
}

ServicePointRow mockServicePointRow(ServicePoint data) {
  final servicePointRow = MockServicePointRow();
  when(servicePointRow.data).thenReturn(data);
  when(servicePointRow.height).thenReturn(ServicePointRow.rowHeight);
  when(servicePointRow.stickyLevel).thenReturn(StickyLevel.first);
  return servicePointRow;
}

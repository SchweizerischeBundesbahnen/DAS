import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/journey.dart';
import 'package:sfera/src/model/journey/metadata.dart';

void main() {
  late ArrivalDepartureTimeViewModel viewModel;
  late StreamController<Journey?> journeyStreamController;

  setUp(() {
    journeyStreamController = StreamController<Journey?>();
    viewModel = ArrivalDepartureTimeViewModel(journeyStream: journeyStreamController.stream);
  });

  tearDown(() {
    viewModel.dispose();
    journeyStreamController.close();
  });

  test('showCalculatedTimes_whenInitialized_thenReturnsTrue', () {
    expect(viewModel.showCalculatedTimes, isTrue);
  });

  test('rxShowCalculatedTimes_whenJourneyIsNull_thenEmitsFalse', () async {
    journeyStreamController.add(null);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await viewModel.rxShowCalculatedTimes.first, isFalse);
  });

  test('rxShowCalculatedTimes_whenJourneyHasNoOperationalArrivalDepartureTimes_thenEmitsFalse', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: false);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await viewModel.rxShowCalculatedTimes.first, isFalse);
  });

  test('rxShowCalculatedTimes_whenJourneyHasOperationalArrivalDepartureTimes_thenEmitsTrue', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: true);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await viewModel.rxShowCalculatedTimes.first, isTrue);
  });

  test('toggleCalculatedTime_whenJourneyHasCalculatedTimes_thenTogglesShowCalculatedTimes', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: true);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(viewModel.showCalculatedTimes, isTrue);

    viewModel.toggleCalculatedTime();
    expect(viewModel.showCalculatedTimes, isFalse);

    viewModel.toggleCalculatedTime();
    expect(viewModel.showCalculatedTimes, isTrue);
  });

  test('toggleCalculatedTime_whenJourneyHasNoCalculatedTimes_thenDoesNothing', () {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: false);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    expect(viewModel.showCalculatedTimes, isTrue);

    viewModel.toggleCalculatedTime();
    // Should remain true
    expect(viewModel.showCalculatedTimes, isTrue);
  });

  test('dispose_whenCalled_thenCancelsSubscriptionAndClosesSubject', () {
    expect(journeyStreamController.hasListener, isTrue);

    viewModel.dispose();

    expect(journeyStreamController.hasListener, isFalse);
  });
}

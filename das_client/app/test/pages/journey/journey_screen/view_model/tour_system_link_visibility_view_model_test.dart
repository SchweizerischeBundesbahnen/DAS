import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_advancement_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/tour_system_link_visibility_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'tour_system_link_visibility_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<JourneyPositionViewModel>(),
  MockSpec<JourneyTableAdvancementViewModel>(),
])
void main() {
  group('TourSystemLinkVisibilityViewModel', () {
    late TourSystemLinkVisibilityViewModel testee;
    late List<dynamic> emitRegister;
    late StreamSubscription sub;

    late MockJourneyViewModel mockJourneyViewModel;
    late MockJourneyPositionViewModel mockJourneyPositionViewModel;
    late MockJourneyTableAdvancementViewModel mockJourneyTableAdvancementViewModel;

    late BehaviorSubject<Journey?> journeySubject;
    late BehaviorSubject<JourneyPositionModel> journeyPositionSubject;
    late BehaviorSubject<JourneyAdvancementModel> journeyAdvancementSubject;

    final journey = Journey(
      metadata: Metadata(),
      data: [
        ServicePoint(name: 'A', abbreviation: '', locationCode: '', order: 0, kilometre: []),
        ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 1, kilometre: []),
        ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 2, kilometre: []),
      ],
    );

    setUp(() {
      mockJourneyViewModel = MockJourneyViewModel();
      mockJourneyPositionViewModel = MockJourneyPositionViewModel();
      mockJourneyTableAdvancementViewModel = MockJourneyTableAdvancementViewModel();
      journeySubject = BehaviorSubject<Journey?>.seeded(journey);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(
        JourneyPositionModel(currentPosition: journey.data.whereType<JourneyPoint>().first),
      );
      journeyAdvancementSubject = BehaviorSubject<JourneyAdvancementModel>.seeded(Automatic());

      when(mockJourneyViewModel.journey).thenAnswer((_) => journeySubject.stream);
      when(mockJourneyPositionViewModel.model).thenAnswer((_) => journeyPositionSubject.stream);
      when(mockJourneyTableAdvancementViewModel.model).thenAnswer((_) => journeyAdvancementSubject.stream);

      testee = TourSystemLinkVisibilityViewModel(
        journeyViewModel: mockJourneyViewModel,
        journeyPositionViewModel: mockJourneyPositionViewModel,
        journeyTableAdvancementViewModel: mockJourneyTableAdvancementViewModel,
      );
      emitRegister = <bool>[];
      sub = testee.model.listen(emitRegister.add);
    });

    tearDown(() {
      sub.cancel();
      testee.dispose();
      journeySubject.close();
      journeyPositionSubject.close();
      journeyAdvancementSubject.close();
    });

    test('initialState_whenInstantiated_thenIsFalse', () async {
      // EXPECT
      expect(testee.modelValue, isFalse);

      await processStreams();
      expect(emitRegister, hasLength(1));
      expect(emitRegister[0], false);
    });

    test('model_whenJourneyTableAdvancementPaused_thenIsTrue', () async {
      // ARRANGE
      await processStreams();

      // ACT
      journeyAdvancementSubject.add(Paused(next: Automatic()));
      await processStreams();

      // EXPECT
      expect(testee.modelValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('model_whenPositionIsLastServicePoint_thenIsTrue', () async {
      // ARRANGE
      await processStreams();

      // ACT
      journeyPositionSubject.add(JourneyPositionModel(currentPosition: journey.data.whereType<ServicePoint>().last));
      await processStreams();

      // EXPECT
      expect(testee.modelValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('model_whenDepartureTimeOfFirstServicePointIsInTheFuture_thenIsTrue', () async {
      // ARRANGE
      final departureJourney = Journey(
        metadata: Metadata(),
        data: [
          ServicePoint(
            name: 'A',
            abbreviation: '',
            locationCode: '',
            order: 0,
            kilometre: [],
            arrivalDepartureTime: ArrivalDepartureTime(
              plannedDepartureTime: DateTime.now().add(const Duration(seconds: 1)),
            ),
          ),
          ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 1, kilometre: []),
          ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 2, kilometre: []),
        ],
      );

      // ACT
      journeySubject.add(departureJourney);
      journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(
        JourneyPositionModel(currentPosition: departureJourney.data.whereType<JourneyPoint>().first),
      );
      await processStreams();

      // EXPECT
      expect(testee.modelValue, isTrue);
      expect(emitRegister.last, isTrue);
    });

    test('model_whenDepartureTimeOfFirstServicePointIsReached_thenIsFalse', () async {
      FakeAsync().run((fakeAsync) {
        testee.dispose();
        emitRegister.clear();
        testee = TourSystemLinkVisibilityViewModel(
          journeyViewModel: mockJourneyViewModel,
          journeyPositionViewModel: mockJourneyPositionViewModel,
          journeyTableAdvancementViewModel: mockJourneyTableAdvancementViewModel,
        );
        testee.model.listen(emitRegister.add);
        fakeAsync.elapse(Duration(milliseconds: 0));

        // ARRANGE
        final departureJourney = Journey(
          metadata: Metadata(),
          data: [
            ServicePoint(
              name: 'A',
              abbreviation: '',
              locationCode: '',
              order: 0,
              kilometre: [],
              arrivalDepartureTime: ArrivalDepartureTime(
                plannedDepartureTime: DateTime.now().add(const Duration(seconds: 1)),
              ),
            ),
            ServicePoint(name: 'B', abbreviation: '', locationCode: '', order: 1, kilometre: []),
            ServicePoint(name: 'C', abbreviation: '', locationCode: '', order: 2, kilometre: []),
          ],
        );

        // ACT
        journeySubject.add(departureJourney);
        journeyPositionSubject = BehaviorSubject<JourneyPositionModel>.seeded(
          JourneyPositionModel(currentPosition: departureJourney.data.whereType<JourneyPoint>().first),
        );
        fakeAsync.elapse(Duration(milliseconds: 0));
        fakeAsync.elapse(Duration(milliseconds: 1500));

        // EXPECT
        expect(emitRegister, hasLength(3));
        expect(emitRegister[0], isFalse);
        expect(emitRegister[1], isTrue);

        expect(testee.modelValue, isFalse);
        expect(emitRegister.last, isFalse);
      });
    });
  });
}

import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/radio_channel_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import 'radio_channel_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  group('RadioChannelViewModel', () {
    late BehaviorSubject<Journey?> rxMockJourney;
    late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
    late RadioChannelViewModel testee;
    final List<dynamic> emitRegister = [];
    late StreamSubscription<RadioChannelModel> modelSubscription;
    late MockJourneyTableViewModel mockJourneyTableViewModel;

    setUp(() {
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      mockJourneyTableViewModel = MockJourneyTableViewModel();
      when(mockJourneyTableViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      testee = RadioChannelViewModel(
        journeyPositionStream: rxMockJourneyPosition.stream,
        journeyTableViewModel: mockJourneyTableViewModel,
      );
      modelSubscription = testee.model.listen(emitRegister.add);
    });

    tearDown(() {
      modelSubscription.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    test('constructor_whenCalled_thenSubscribesToStreams', () {
      expect(rxMockJourney.hasListener, isTrue);
    });

    test('model_whenJourneyNull_thenAllValuesNull', () => expect(testee.modelValue, equals(RadioChannelModel())));

    test('model_whenJourneyWithLastServicePoint_thenLastServicePointIsEqual', () async {
      // ARRANGE
      final aServicePoint = ServicePoint(name: 'A', abbreviation: '', order: 0, kilometre: [0]);
      rxMockJourneyPosition.add(JourneyPositionModel(previousServicePoint: aServicePoint));
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(lastServicePoint: aServicePoint)));
    });

    test('model_whenJourneyWithSingleRadioContactListAndCurrentPositionIsNull_thenHasNoRadioContactList', () async {
      // ARRANGE
      final aRadioContactList = RadioContactList(
        order: 0,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      rxMockJourney.add(mockJourney(radioContacts: [aRadioContactList]));
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithSingleRadioContactListAndCurrentPositionBefore_thenHasNoRadioContactList', () async {
      // ARRANGE
      final aRadioContactList = RadioContactList(
        order: 10,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 5, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithSingleRadioContactListAndCurrentPositionAfterOrEqual_thenHasRadioContactList', () async {
      // ARRANGE
      final aRadioContactList = RadioContactList(
        order: 5,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 5, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(radioContacts: aRadioContactList)));
    });

    test('model_whenJourneyWithTwoRadioContactListsAndCurrentPosition_thenMatchingRadioContactList', () async {
      // ARRANGE
      final aRadioContactList = RadioContactList(
        order: 5,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      final bRadioContactList = RadioContactList(
        order: 15,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 20, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList, bRadioContactList],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(radioContacts: bRadioContactList)));
    });

    test('model_whenJourneyWithCommunicationNetworkAndNoCurrentPosition_thenHasNoCommuncationNetworkType', () async {
      // ARRANGE
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [
            CommunicationNetworkChange(communicationNetworkType: .sim, order: 0),
          ],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithCommunicationNetworkAndCurrentPositionBefore_thenHasNoNetworkType', () async {
      // ARRANGE
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 5, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [
            CommunicationNetworkChange(communicationNetworkType: .sim, order: 10),
          ],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithCommunicationNetworkAndCurrentPositionAfterOrEqual_thenHasNetworkType', () async {
      // ARRANGE
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 15, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [
            CommunicationNetworkChange(
              communicationNetworkType: .sim,
              order: 10,
              kilometre: [0.0],
            ),
          ],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: .sim)));
    });

    test('model_whenJourneyWithTwoCommunicationNetworksAndCurrentPosition_thenHasNetworkType', () async {
      // ARRANGE
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: Signal(order: 20, kilometre: [0.0])));
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [
            CommunicationNetworkChange(
              communicationNetworkType: .sim,
              order: 10,
              kilometre: [0.0],
            ),
            CommunicationNetworkChange(
              communicationNetworkType: .gsmP,
              order: 20,
              kilometre: [0.0],
            ),
          ],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: .gsmP)));
    });
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

Journey mockJourney({
  Iterable<RadioContactList> radioContacts = const [],
  List<CommunicationNetworkChange> communicationNetworkChanges = const [],
}) => Journey(
  metadata: Metadata(
    radioContactLists: radioContacts,
    communicationNetworkChanges: communicationNetworkChanges,
  ),
  data: [],
);

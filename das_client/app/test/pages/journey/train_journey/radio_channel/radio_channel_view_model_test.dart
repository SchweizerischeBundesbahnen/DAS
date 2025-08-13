import 'dart:async';

import 'package:app/pages/journey/train_journey/radio_channel/radio_channel_model.dart';
import 'package:app/pages/journey/train_journey/radio_channel/radio_channel_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

void main() {
  group('RadioChannelViewModel', () {
    late BehaviorSubject<Journey?> rxMockJourney;
    late RadioChannelViewModel testee;
    final List<dynamic> emitRegister = [];
    late StreamSubscription<RadioChannelModel> modelSubscription;

    setUp(() {
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      testee = RadioChannelViewModel(journeyStream: rxMockJourney.stream);
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
      final aServicePoint = ServicePoint(name: 'A', order: 0, kilometre: [0]);
      rxMockJourney.add(mockJourney(servicePoint: aServicePoint));
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
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList],
          currentPosition: Signal(order: 5, kilometre: [0.0]),
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
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList],
          currentPosition: Signal(order: 5, kilometre: [0.0]),
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
      rxMockJourney.add(
        mockJourney(
          radioContacts: [aRadioContactList, bRadioContactList],
          currentPosition: Signal(order: 20, kilometre: [0.0]),
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
          communicationNetworkChanges: [CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 0)],
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithCommunicationNetworkAndCurrentPositionBefore_thenHasNoNetworkType', () async {
      // ARRANGE
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 10)],
          currentPosition: Signal(order: 5, kilometre: [0.0]),
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.last, equals(RadioChannelModel()));
    });

    test('model_whenJourneyWithCommunicationNetworkAndCurrentPositionAfterOrEqual_thenHasNetworkType', () async {
      // ARRANGE
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 10)],
          currentPosition: Signal(order: 15, kilometre: [0.0]),
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: CommunicationNetworkType.sim)));
    });

    test('model_whenJourneyWithTwoCommunicationNetworksAndCurrentPosition_thenHasNetworkType', () async {
      // ARRANGE
      rxMockJourney.add(
        mockJourney(
          communicationNetworkChanges: [
            CommunicationNetworkChange(type: CommunicationNetworkType.sim, order: 10),
            CommunicationNetworkChange(type: CommunicationNetworkType.gsmP, order: 20),
          ],
          currentPosition: Signal(order: 20, kilometre: [0.0]),
        ),
      );
      await _streamProcessing();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: CommunicationNetworkType.gsmP)));
    });
  });
}

Future<void> _streamProcessing() async => Future.delayed(Duration.zero);

Journey mockJourney({
  ServicePoint? servicePoint,
  Iterable<RadioContactList> radioContacts = const [],
  List<CommunicationNetworkChange> communicationNetworkChanges = const [],
  BaseData? currentPosition,
}) => Journey(
  metadata: Metadata(
    lastServicePoint: servicePoint,
    radioContactLists: radioContacts,
    communicationNetworkChanges: communicationNetworkChanges,
    currentPosition: currentPosition,
  ),
  data: [],
);

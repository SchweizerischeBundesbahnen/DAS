import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/radio_channel_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/radio_channel_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../../test_util.dart';
import 'radio_channel_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
])
void main() {
  group('RadioChannelViewModel', () {
    late BehaviorSubject<Journey?> rxMockJourney;
    late BehaviorSubject<JourneyPositionModel> rxMockJourneyPosition;
    late RadioChannelViewModel testee;
    final List<dynamic> emitRegister = [];
    late StreamSubscription<RadioChannelModel> modelSubscription;
    late MockJourneyViewModel mockJourneyViewModel;

    setUp(() {
      rxMockJourney = BehaviorSubject<Journey?>.seeded(null);
      rxMockJourneyPosition = BehaviorSubject<JourneyPositionModel>.seeded(JourneyPositionModel());
      mockJourneyViewModel = MockJourneyViewModel();
      when(mockJourneyViewModel.journey).thenAnswer((_) => rxMockJourney.stream);
      testee = RadioChannelViewModel(
        journeyPositionStream: rxMockJourneyPosition.stream,
        journeyViewModel: mockJourneyViewModel,
      );
      modelSubscription = testee.model.listen(emitRegister.add);
    });

    tearDown(() {
      modelSubscription.cancel();
      emitRegister.clear();
      testee.dispose();
      rxMockJourney.close();
    });

    const zeroOrderServicePoint = ServicePoint(name: 'A', abbreviation: '', locationCode: '', order: 0, kilometre: [0]);
    const twentyOrderServicePoint = ServicePoint(
      name: 'A',
      abbreviation: '',
      locationCode: '',
      order: 20,
      kilometre: [20],
    );

    test('constructor_whenCalled_thenSubscribesToStreams', () {
      expect(rxMockJourney.hasListener, isTrue);
    });

    test('model_whenJourneyNull_thenAllValuesNull', () => expect(testee.modelValue, equals(RadioChannelModel())));

    test('model_whenJourneyWithLastServicePoint_thenLastServicePointIsEqual', () async {
      // ARRANGE
      rxMockJourneyPosition.add(JourneyPositionModel(previousServicePoint: zeroOrderServicePoint));
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(lastServicePoint: zeroOrderServicePoint)));
    });

    test('model_whenJourneyWithSingleRadioContactListAndCurrentPositionIsNull_thenHasNoRadioContactList', () async {
      // ARRANGE
      final aRadioContactList = RadioContactList(
        order: 0,
        endOrder: 0,
        contacts: [MainContact(contactIdentifier: '123')],
      );
      rxMockJourney.add(mockJourney(radioContacts: [aRadioContactList]));
      await processStreams();

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
      await processStreams();

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
      await processStreams();

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
      await processStreams();

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
      await processStreams();

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
      await processStreams();

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
      await processStreams();

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
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: .gsmP)));
    });

    test('model_whenJourneyWithEntrySignalAndNonServicePointFollowingJourneyPoint_thenHasNetworkType', () async {
      // ARRANGE
      const entrySignal = Signal(order: 18, kilometre: [0.0], functions: [.entry]);
      const blocker = Signal(order: 19, kilometre: [0.0], functions: [.block]);

      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: entrySignal));

      rxMockJourney.add(
        mockJourney(
          data: [entrySignal, blocker, twentyOrderServicePoint],
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
              isServicePoint: true,
            ),
          ],
        ),
      );
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(emitRegister.last, equals(RadioChannelModel(networkType: .sim)));
    });

    test('model_whenJourneyWithEntrySignalAndServicePointWithoutChangesFollowing_thenHasCurrentNetworkType', () async {
      // ARRANGE
      const entrySignal = Signal(order: 18, kilometre: [0.0], functions: [.entry]);
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: entrySignal));
      rxMockJourney.add(
        mockJourney(
          data: [entrySignal, twentyOrderServicePoint],
          communicationNetworkChanges: [
            CommunicationNetworkChange(
              communicationNetworkType: .sim,
              order: 10,
              kilometre: [0.0],
            ),
          ],
        ),
      );
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister.last,
        equals(RadioChannelModel(networkType: .sim, lastServicePoint: twentyOrderServicePoint)),
      );
    });

    test('model_whenJourneyWithEntrySignalAndServicePointWithChanges_thenHasNextNetworkType', () async {
      // ARRANGE
      const entrySignal = Signal(order: 18, kilometre: [0.0], functions: [.entry]);
      rxMockJourneyPosition.add(JourneyPositionModel(currentPosition: entrySignal));
      rxMockJourney.add(
        mockJourney(
          data: [entrySignal, twentyOrderServicePoint],
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
              isServicePoint: true,
            ),
          ],
        ),
      );
      await processStreams();

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(
        emitRegister.last,
        equals(RadioChannelModel(networkType: .gsmP, lastServicePoint: twentyOrderServicePoint)),
      );
    });
  });
}

Journey mockJourney({
  Iterable<RadioContactList> radioContacts = const [],
  List<CommunicationNetworkChange> communicationNetworkChanges = const [],
  List<BaseData> data = const [],
}) => Journey(
  metadata: Metadata(
    radioContactLists: radioContacts,
    communicationNetworkChanges: communicationNetworkChanges,
  ),
  data: data,
);

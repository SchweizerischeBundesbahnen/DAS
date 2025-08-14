import 'dart:async';

import 'package:app/pages/journey/train_journey/header/radio_channel/radio_channel_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class RadioChannelViewModel {
  RadioChannelViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel> journeyPositionStream,
  }) {
    _initSubscriptions(journeyStream, journeyPositionStream);
  }

  late StreamSubscription<Journey?> _journeySubscription;
  late StreamSubscription<JourneyPositionModel> _positionSubscription;

  final BehaviorSubject<RadioChannelModel> _rxModel = BehaviorSubject.seeded(RadioChannelModel());

  // internal state variables
  final List<RadioContactList> _radioContactLists = [];
  final List<CommunicationNetworkChange> _networkChanges = [];
  ServicePoint? _lastServicePoint;
  JourneyPoint? _currentPosition;

  Stream<RadioChannelModel> get model => _rxModel.stream.distinct();

  RadioChannelModel get modelValue => _rxModel.value;

  void dispose() {
    _journeySubscription.cancel();
    _positionSubscription.cancel();
  }

  void _initSubscriptions(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> journeyPositionStream) {
    _journeySubscription = journeyStream.listen((j) => _handleJourneyUpdate(j));
    _positionSubscription = journeyPositionStream.listen((p) => _handlePositionUpdate(p));
  }

  void _handleJourneyUpdate(Journey? journey) {
    _radioContactLists.clear();
    _networkChanges.clear();

    if (journey != null) {
      final metadata = journey.metadata;
      _radioContactLists.addAll(metadata.radioContactLists);
      _networkChanges.addAll(metadata.communicationNetworkChanges);
    }

    _emitModel();
  }

  void _handlePositionUpdate(JourneyPositionModel p) {
    _currentPosition = p.currentPosition;
    _lastServicePoint = p.previousServicePoint;

    _emitModel();
  }

  void _emitModel() {
    _rxModel.add(
      RadioChannelModel(
        lastServicePoint: _lastServicePoint,
        radioContacts: _radioContactsForCurrentPosition(),
        networkType: _networkTypeForCurrentPosition(),
      ),
    );
  }

  RadioContactList? _radioContactsForCurrentPosition() =>
      _currentPosition != null ? _radioContactLists.lastBefore(_currentPosition!.order) : null;

  CommunicationNetworkType? _networkTypeForCurrentPosition() =>
      _currentPosition != null ? _networkChanges.typeByLastBefore(_currentPosition!.order) : null;
}

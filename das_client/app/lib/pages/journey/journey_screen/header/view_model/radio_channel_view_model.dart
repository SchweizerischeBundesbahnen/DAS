import 'dart:async';

import 'package:app/pages/journey/journey_screen/header/view_model/model/radio_channel_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class RadioChannelViewModel extends JourneyAwareViewModel {
  RadioChannelViewModel({
    required Stream<JourneyPositionModel> journeyPositionStream,
    super.journeyTableViewModel,
  }) {
    _initSubscriptions(journeyTableViewModel.journey, journeyPositionStream);
  }

  late StreamSubscription<(Journey?, JourneyPositionModel)> _subscription;

  final BehaviorSubject<RadioChannelModel> _rxModel = BehaviorSubject.seeded(RadioChannelModel());

  // internal state variables
  final List<RadioContactList> _radioContactLists = [];
  final List<CommunicationNetworkChange> _networkChanges = [];
  ServicePoint? _lastServicePoint;
  JourneyPoint? _currentPosition;

  Stream<RadioChannelModel> get model => _rxModel.stream.distinct();

  RadioChannelModel get modelValue => _rxModel.value;

  void _initSubscriptions(Stream<Journey?> journeyStream, Stream<JourneyPositionModel> journeyPositionStream) {
    _subscription = CombineLatestStream.combine2(journeyStream, journeyPositionStream, (a, b) => (a, b)).listen((snap) {
      final journey = snap.$1;
      final journeyPosition = snap.$2;

      _radioContactLists.clear();
      _networkChanges.clear();

      _currentPosition = journeyPosition.currentPosition;
      _lastServicePoint = journeyPosition.previousServicePoint;

      if (journey != null) {
        final metadata = journey.metadata;
        _radioContactLists.addAll(metadata.radioContactLists);
        _networkChanges.addAll(metadata.communicationNetworkChanges);
      }

      _emitModel();
    });
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

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _rxModel.add(RadioChannelModel());
    _radioContactLists.clear();
    _networkChanges.clear();
    _lastServicePoint = null;
    _currentPosition = null;
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _rxModel.close();
  }
}

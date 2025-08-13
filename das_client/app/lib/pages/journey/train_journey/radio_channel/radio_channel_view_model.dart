import 'dart:async';

import 'package:app/pages/journey/train_journey/radio_channel/radio_channel_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class RadioChannelViewModel {
  RadioChannelViewModel({required Stream<Journey?> journeyStream}) {
    _initSubscriptions(journeyStream);
  }

  late StreamSubscription<Journey?> _journeySubscription;
  final BehaviorSubject<RadioChannelModel> _rxModel = BehaviorSubject.seeded(RadioChannelModel());

  Stream<RadioChannelModel> get model => _rxModel.stream.distinct();

  RadioChannelModel get modelValue => _rxModel.value;

  void dispose() {
    _journeySubscription.cancel();
  }

  void _initSubscriptions(Stream<Journey?> journeyStream) {
    _journeySubscription = journeyStream.listen((journey) {
      if (journey == null) return _rxModel.add(RadioChannelModel());

      final metadata = journey.metadata;
      _rxModel.add(
        RadioChannelModel(
          lastServicePoint: metadata.lastServicePoint,
          radioContacts: _radioContactsForCurrentPosition(
            metadata.currentPosition,
            metadata.radioContactLists,
          ),
          networkType: _networkTypeForCurrentPosition(
            metadata.currentPosition,
            metadata.communicationNetworkChanges,
          ),
        ),
      );
    });
  }

  RadioContactList? _radioContactsForCurrentPosition(
    BaseData? currentPosition,
    Iterable<RadioContactList> radioContactLists,
  ) => currentPosition != null ? radioContactLists.lastBefore(currentPosition.order) : null;

  CommunicationNetworkType? _networkTypeForCurrentPosition(
    BaseData? currentPosition,
    List<CommunicationNetworkChange> communicationNetworkChanges,
  ) => currentPosition != null ? communicationNetworkChanges.typeByLastBefore(currentPosition.order) : null;
}

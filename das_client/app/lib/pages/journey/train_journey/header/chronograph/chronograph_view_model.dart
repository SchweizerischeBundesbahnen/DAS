import 'dart:async';
import 'dart:collection';

import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/pages/journey/train_journey/punctuality/punctuality_model.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/adl_view_model.dart';
import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class ChronographViewModel {
  static const String trainIsPunctualString = '+00:00';

  ChronographViewModel({
    required Stream<Journey?> journeyStream,
    required Stream<JourneyPositionModel?> journeyPositionStream,
    required Stream<PunctualityModel> punctualityStream,
    required Stream<AdlState> adlStateStream,
  }) {
    _initJourneySubscription(journeyStream);
    _initJourneyPositionSubscription(journeyPositionStream);
    _initPunctualitySubscription(punctualityStream);
    _initAdlSubscription(adlStateStream);
  }

  bool _isAdlActive = false;
  ServicePoint? _lastServicePoint;
  SplayTreeMap<int, SingleSpeed?>? _calculatedSpeeds;

  PunctualityModel _punctualityModel = PunctualityModel.hidden();

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  final _rxModel = BehaviorSubject<PunctualityModel>.seeded(PunctualityModel.hidden());

  Stream<PunctualityModel> get punctualityModel => _rxModel.distinct();

  PunctualityModel get punctualityModelValue => _rxModel.value;

  Stream<String> get formattedWallclockTime => Stream.periodic(
    const Duration(milliseconds: 200),
    (_) => DateFormat('HH:mm:ss').format(clock.now()),
  ).distinct();

  String get formattedWallclockTimeValue => DateFormat('HH:mm:ss').format(clock.now());

  void dispose() {
    _cancelSubscriptions();
    _subscriptions.clear();
    _rxModel.close();
  }

  void _cancelSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void _initJourneySubscription(Stream<Journey?> journeyStream) {
    _subscriptions.add(
      journeyStream.listen((journey) {
        _calculatedSpeeds = journey?.metadata.calculatedSpeeds;

        _emitState();
      }),
    );
  }

  void _initJourneyPositionSubscription(Stream<JourneyPositionModel?> journeyPositionStream) {
    _subscriptions.add(
      journeyPositionStream.listen((model) {
        _lastServicePoint = model?.previousServicePoint;

        _emitState();
      }),
    );
  }

  void _initPunctualitySubscription(Stream<PunctualityModel> punctualityStream) {
    _subscriptions.add(
      punctualityStream.listen((punctualityModel) {
        _punctualityModel = punctualityModel;

        _emitState();
      }),
    );
  }

  void _initAdlSubscription(Stream<AdlState> adlStateStream) {
    _subscriptions.add(
      adlStateStream.listen((adlState) {
        _isAdlActive = adlState == AdlState.active;

        _emitState();
      }),
    );
  }

  void _emitState() {
    if (!_hasLastServicePointCalculatedSpeed || _isAdlActive) return _rxModel.add(PunctualityModel.hidden());
    _rxModel.add(_punctualityModel);
  }

  bool get _hasLastServicePointCalculatedSpeed {
    final lastServicePointOrder = _lastServicePoint?.order;
    return lastServicePointOrder != null &&
        _calculatedSpeeds != null &&
        _calculatedSpeeds![lastServicePointOrder] != null;
  }
}

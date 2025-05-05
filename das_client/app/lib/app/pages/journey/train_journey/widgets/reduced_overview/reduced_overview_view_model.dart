import 'dart:async';

import 'package:sfera/component.dart';
import 'package:rxdart/rxdart.dart';

class ReducedOverviewViewModel {
  ReducedOverviewViewModel({
    required this.trainIdentification,
    required SferaLocalService sferaLocalService,
  }) : _sferaLocalService = sferaLocalService {
    _init();
  }

  final SferaLocalService _sferaLocalService;

  final TrainIdentification trainIdentification;

  final _rxJourney = BehaviorSubject<Journey>();
  final _rxJourneyData = BehaviorSubject<List<BaseData>>();
  final _rxJourneyMetadata = BehaviorSubject<Metadata>();
  final _subscriptions = <StreamSubscription>[];

  Stream<List<BaseData>> get journeyData => _rxJourneyData.stream;

  Stream<Metadata> get journeyMetadata => _rxJourneyMetadata.stream;

  Future<void> _init() async {
    await _initRxJourney();
    await _initRxJourneyData();
    await _initRxJourneyMetadata();
  }

  Future<void> _initRxJourney() async {
    final company = trainIdentification.ru.companyCode;
    final trainNumber = trainIdentification.trainNumber;
    final date = trainIdentification.date;
    final subscription =
        _sferaLocalService.journeyStream(company: company, trainNumber: trainNumber, startDate: date).listen((data) {
      if (data != null) {
        _rxJourney.add(data);
      }
    }, onError: _rxJourney.addError);
    _subscriptions.add(subscription);
  }

  Future<void> _initRxJourneyMetadata() async {
    final subscription = _rxJourney.stream
        .map((journey) => journey.metadata)
        .listen(_rxJourneyMetadata.add, onError: _rxJourneyMetadata.addError);
    _subscriptions.add(subscription);
  }

  Future<void> _initRxJourneyData() async {
    final subscription = _rxJourney.stream
        .map((journey) => _relevantDataForReducedOverview(journey))
        .listen(_rxJourneyData.add, onError: _rxJourneyData.addError);
    _subscriptions.add(subscription);
  }

  List<BaseData> _relevantDataForReducedOverview(Journey journey) {
    final relevantData = journey.data.where((it) => _relevantForReducedOverview(it, journey.metadata)).toList();
    _removeDuplicatedASR(relevantData);
    return relevantData;
  }

  void _removeDuplicatedASR(List<BaseData> data) {
    for (int i = 1; i < data.length; i++) {
      final current = data[i];
      final previous = data[i - 1];
      if (current is AdditionalSpeedRestrictionData && previous is AdditionalSpeedRestrictionData) {
        if (current.restriction == previous.restriction) {
          data.removeAt(i);
          i--;
        }
      }
    }
  }

  bool _relevantForReducedOverview(BaseData data, Metadata metadata) {
    final isServicePointWithStop = data.type == Datatype.servicePoint && (data as ServicePoint).isStop;
    final isNetworkChange = metadata.communicationNetworkChanges.changeAtOrder(data.order) != null;
    return isServicePointWithStop || isNetworkChange || data.type == Datatype.additionalSpeedRestriction;
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _rxJourney.close();
    _rxJourneyData.close();
    _rxJourneyMetadata.close();
  }
}

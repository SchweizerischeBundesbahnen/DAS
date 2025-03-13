import 'dart:async';

import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/train_identification.dart';
import 'package:das_client/sfera/sfera_component.dart';
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
    _initRxJourney();
    _initRxJourneyData();
    _initRxJourneyMetadata();
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
        .map((journey) => journey.data)
        .map((journeyData) => journeyData.where((data) => _relevantForReducedOverview(data)).toList())
        .listen(_rxJourneyData.add, onError: _rxJourneyData.addError);
    _subscriptions.add(subscription);
  }

  bool _relevantForReducedOverview(BaseData data) {
    final isServicePointWithStop = data.type == Datatype.servicePoint && (data as ServicePoint).isStop;
    return isServicePointWithStop || data.type == Datatype.additionalSpeedRestriction;
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

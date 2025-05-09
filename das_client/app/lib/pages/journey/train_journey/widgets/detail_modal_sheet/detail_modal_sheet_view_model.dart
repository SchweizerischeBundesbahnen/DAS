import 'dart:async';
import 'dart:ui';

import 'package:app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DetailModalSheetViewModel {
  DetailModalSheetViewModel({required this.onOpen}) {
    _init();
  }

  final VoidCallback onOpen;
  late DASModalSheetController controller;

  final _rxCommunicationNetworkType = BehaviorSubject<CommunicationNetworkType?>();
  final _rxRadioContactList = BehaviorSubject<RadioContactList?>();
  final _rxMetadata = BehaviorSubject<Metadata>();
  final _rxServicePoint = BehaviorSubject<ServicePoint>();
  final _rxIsModalSheetOpen = BehaviorSubject.seeded(false);
  final _rxSelectedTab = BehaviorSubject.seeded(DetailModalSheetTab.values.first);
  final _rxSettings = BehaviorSubject<TrainJourneySettings>();
  final _rxRelevantSpeedInfo = BehaviorSubject.seeded(<Speeds>[]);
  final _rxBreakSeries = BehaviorSubject<BreakSeries?>();
  final _subscriptions = <StreamSubscription>[];

  Stream<DetailModalSheetTab> get selectedTab => _rxSelectedTab.distinct();

  Stream<bool> get isModalSheetOpen => _rxIsModalSheetOpen.distinct();

  Stream<ServicePoint> get servicePoint => _rxServicePoint.distinct();

  Stream<RadioContactList?> get radioContacts => _rxRadioContactList.distinct();

  Stream<CommunicationNetworkType?> get communicationNetworkType => _rxCommunicationNetworkType.distinct();

  Stream<List<Speeds>> get relevantSpeedInfo => _rxRelevantSpeedInfo.distinct();

  Stream<BreakSeries?> get breakSeries => _rxBreakSeries.distinct();

  void _init() {
    _initController();
    _initRadioContacts();
    _initCommunicationNetworkType();
    _initRelevantSpeedInfo();
  }

  void _initRadioContacts() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.radioContactLists.lastLowerThan(servicePoint.order),
    ).listen(_rxRadioContactList.add, onError: _rxRadioContactList.addError);
    _subscriptions.add(subscription);
  }

  void _initRelevantSpeedInfo() {
    final subscription = Rx.combineLatest3(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      _rxSettings.stream,
      (servicePoint, metadata, settings) {
        final currentBreakSeries = settings.resolvedBreakSeries(metadata);
        _rxBreakSeries.add(currentBreakSeries);

        return servicePoint.relevantGraduatedSpeedInfo(currentBreakSeries);
      },
    ).listen(_rxRelevantSpeedInfo.add, onError: _rxRelevantSpeedInfo.addError);
    _subscriptions.add(subscription);
  }

  void _initCommunicationNetworkType() {
    final subscription = Rx.combineLatest2(
      _rxServicePoint.stream,
      _rxMetadata.stream,
      (servicePoint, metadata) => metadata.communicationNetworkChanges.appliesToOrder(servicePoint.order),
    ).listen(_rxCommunicationNetworkType.add, onError: _rxCommunicationNetworkType.addError);
    _subscriptions.add(subscription);
  }

  void _initController() {
    controller = DASModalSheetController(
      onClose: () => _rxIsModalSheetOpen.add(false),
      onOpen: () {
        _rxIsModalSheetOpen.add(true);
        onOpen.call();
      },
    );
  }

  void updateMetadata(Metadata metadata) => _rxMetadata.add(metadata);

  void updateSettings(TrainJourneySettings settings) => _rxSettings.add(settings);

  void open({DetailModalSheetTab? tab, ServicePoint? servicePoint}) {
    if (tab != null) {
      _rxSelectedTab.add(tab);
    }
    if (servicePoint != null) {
      _rxServicePoint.add(servicePoint);
    }

    if (tab == DetailModalSheetTab.localRegulations) {
      controller.maximize();
    } else {
      controller.expand();
    }
  }

  void close() => controller.close();

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _rxMetadata.close();
    _rxSelectedTab.close();
    _rxIsModalSheetOpen.close();
    _rxCommunicationNetworkType.close();
    _rxServicePoint.close();
    _rxSettings.close();
    _rxRelevantSpeedInfo.close();
    _rxBreakSeries.close();
    controller.dispose();
  }
}

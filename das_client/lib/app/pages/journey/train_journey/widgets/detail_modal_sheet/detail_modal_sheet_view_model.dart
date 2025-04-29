import 'dart:async';

import 'package:das_client/app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:das_client/model/journey/contact_list.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/speeds.dart';
import 'package:rxdart/rxdart.dart';

class DetailModalSheetViewModel {
  DetailModalSheetViewModel({required this.automaticAdvancementController}) {
    _init();
  }

  final AutomaticAdvancementController automaticAdvancementController;
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
    final isAutoCloseActive = _rxSettings.valueOrNull?.isAutoAdvancementEnabled ?? true;
    print('hello $isAutoCloseActive');
    controller = DASModalSheetController(
      isAutomaticCloseActive: isAutoCloseActive,
      onClose: () => _rxIsModalSheetOpen.add(false),
      onOpen: () {
        _rxIsModalSheetOpen.add(true);
        if (isAutoCloseActive) {
          automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
        }
      },
    );

    final subscription = automaticAdvancementController.isActiveStream
        .listen((value) => controller.setAutomaticClose(isActivated: value));
    _subscriptions.add(subscription);
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

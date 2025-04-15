import 'dart:async';

import 'package:das_client/app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:rxdart/rxdart.dart';

class DetailModalSheetViewModel {
  DetailModalSheetViewModel({required this.automaticAdvancementController}) {
    _init();
  }

  final AutomaticAdvancementController automaticAdvancementController;
  late DASModalSheetController controller;

  final _rxServicePoint = BehaviorSubject<ServicePoint>();
  final _rxIsModalSheetOpen = BehaviorSubject.seeded(false);
  final _rxSelectedTab = BehaviorSubject.seeded(DetailModalSheetTab.values.first);
  final _subscriptions = <StreamSubscription>[];

  Stream<DetailModalSheetTab> get selectedTab => _rxSelectedTab.distinct();

  Stream<bool> get isModalSheetOpen => _rxIsModalSheetOpen.distinct();

  Stream<ServicePoint> get servicePoint => _rxServicePoint.distinct();

  void _init() {
    controller = DASModalSheetController(
      isAutomaticCloseActive: automaticAdvancementController.isActive,
      onClose: () => _rxIsModalSheetOpen.add(false),
      onOpen: () {
        _rxIsModalSheetOpen.add(true);
        automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancement: true);
      },
    );

    final subscription = automaticAdvancementController.isActiveStream
        .listen((value) => controller.setAutomaticClose(isActivated: value));
    _subscriptions.add(subscription);
  }

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
    _rxSelectedTab.close();
    _rxIsModalSheetOpen.close();
    _rxServicePoint.close();
    controller.dispose();
  }
}

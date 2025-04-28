import 'dart:async';

import 'package:das_client/app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

class BaseModalSheetViewModel {
  BaseModalSheetViewModel({required this.automaticAdvancementController}) {
    _init();
  }

  final AutomaticAdvancementController automaticAdvancementController;
  late DASModalSheetController controller;

  final _rxContentBuilder = BehaviorSubject<DASModalSheetBuilder?>();
  final _rxIsModalSheetOpen = BehaviorSubject.seeded(false);
  final _subscriptions = <StreamSubscription>[];

  Stream<bool> get isModalSheetOpen => _rxIsModalSheetOpen.distinct();

  Stream<DASModalSheetBuilder?> get contentBuilder => _rxContentBuilder.distinct();

  void _init() {
    _initController();
  }

  void _initController() {
    controller = DASModalSheetController(
      isAutomaticCloseActive: automaticAdvancementController.isActive,
      onClose: () => _rxIsModalSheetOpen.add(false),
      onOpen: () {
        _rxIsModalSheetOpen.add(true);
        if (automaticAdvancementController.isActive) {
          automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
        }
      },
    );

    final subscription = automaticAdvancementController.isActiveStream
        .listen((value) => controller.setAutomaticClose(isActivated: value));
    _subscriptions.add(subscription);
  }

  void open(DASModalSheetBuilder builder, {bool maximize = false}) {
    _rxContentBuilder.add(builder);
    if (maximize) {
      controller.maximize();
    } else {
      controller.expand();
    }
  }

  void close() {
    controller.close();
    _rxContentBuilder.add(null);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _rxIsModalSheetOpen.close();
    _rxContentBuilder.close();
    controller.dispose();
  }
}

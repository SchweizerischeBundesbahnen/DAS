import 'dart:async';

import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

class DetailModalSheetViewModel {
  DetailModalSheetViewModel() {
    _init();
  }

  late DASModalSheetController controller;

  final _rxIsModalSheetOpen = BehaviorSubject.seeded(false);
  final _rxSelectedTab = BehaviorSubject.seeded(DetailModalSheetTab.values.first);
  final _subscriptions = <StreamSubscription>[];

  Stream<DetailModalSheetTab> get selectedTab => _rxSelectedTab.stream;

  Stream<bool> get isModalSheetOpen => _rxIsModalSheetOpen.stream;

  void _init() {
    controller = DASModalSheetController(
      onClose: () => _rxIsModalSheetOpen.add(false),
      onOpen: () => _rxIsModalSheetOpen.add(true),
    );
  }

  void open({DetailModalSheetTab? tab}) {
    if (tab != null) {
      _rxSelectedTab.add(tab);
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
    controller.dispose();
  }
}

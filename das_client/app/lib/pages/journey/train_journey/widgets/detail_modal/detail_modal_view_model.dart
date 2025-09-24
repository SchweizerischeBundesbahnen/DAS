import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

class DetailModalViewModel {
  DetailModalViewModel({required this.automaticAdvancementController}) {
    _init();
  }

  final AutomaticAdvancementController automaticAdvancementController;
  late DASModalSheetController controller;

  final _rxContentBuilder = BehaviorSubject<DASModalSheetBuilder?>();
  final _rxIsModalOpen = BehaviorSubject.seeded(false);

  bool get isModalOpenValue => _rxIsModalOpen.value;

  Stream<bool> get isModalOpen => _rxIsModalOpen.distinct();

  Stream<DASModalSheetBuilder?> get contentBuilder => _rxContentBuilder.distinct();

  void _init() {
    _initController();
  }

  void _initController() {
    controller = DASModalSheetController(
      onClose: () => _rxIsModalOpen.add(false),
      onOpen: () {
        _rxIsModalOpen.add(true);
        if (automaticAdvancementController.isActive) {
          automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
        }
      },
    );
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
    _rxIsModalOpen.close();
    _rxContentBuilder.close();
  }
}

import 'dart:async';

import 'package:app/pages/journey/train_journey/automatic_advancement_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

enum DetailModalType { servicePointModal, additionalSpeedRestriction }

class DetailModalViewModel {
  DetailModalViewModel({required this.automaticAdvancementController}) {
    _init();
  }

  final AutomaticAdvancementController automaticAdvancementController;
  late DASModalSheetController controller;

  final _rxContentBuilder = BehaviorSubject<DASModalSheetBuilder?>();
  final _rxOpenModalType = BehaviorSubject<DetailModalType?>.seeded(null);

  bool get isModalOpenValue => _rxOpenModalType.value != null;

  Stream<DetailModalType?> get openModalType => _rxOpenModalType.distinct();

  Stream<bool> get isModalOpen => _rxOpenModalType.map((type) => type != null);

  Stream<DASModalSheetBuilder?> get contentBuilder => _rxContentBuilder.distinct();

  void _init() {
    _initController();
  }

  void _initController() {
    controller = DASModalSheetController(
      onClose: () => _rxOpenModalType.add(null),
      onOpen: () {
        if (automaticAdvancementController.isActive) {
          automaticAdvancementController.scrollToCurrentPosition(resetAutomaticAdvancementTimer: true);
        }
      },
    );
  }

  void open(DASModalSheetBuilder builder, {bool maximize = false}) {
    switch (builder) {
      case AdditionalSpeedRestrictionModalBuilder():
        _rxOpenModalType.add(DetailModalType.additionalSpeedRestriction);
      case ServicePointModalBuilder():
        _rxOpenModalType.add(DetailModalType.servicePointModal);
    }

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
    _rxOpenModalType.close();
    _rxContentBuilder.close();
  }
}

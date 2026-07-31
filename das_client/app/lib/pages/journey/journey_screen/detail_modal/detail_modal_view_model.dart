import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

enum DetailModalType { servicePointModal, additionalSpeedRestriction, brakeSlip }

class DetailModalViewModel {
  DetailModalViewModel() {
    _init();
  }

  late DASModalSheetController controller;

  final _rxContentBuilder = BehaviorSubject<DASModalSheetBuilder?>();
  final _rxOpenModalType = BehaviorSubject<DetailModalType?>.seeded(null);

  /// Identifies which concrete content of [openModalTypeValue] is currently displayed (e.g. the tapped
  /// service point + tab, or the tapped ASR row). Re-opening with the same type and key closes the modal.
  Object? _openContentKey;

  bool get isModalOpenValue => _rxOpenModalType.value != null;

  Stream<DetailModalType?> get openModalType => _rxOpenModalType.distinct();

  DetailModalType? get openModalTypeValue => _rxOpenModalType.value;

  Stream<bool> get isModalOpen => _rxOpenModalType.map((type) => type != null);

  Stream<DASModalSheetBuilder?> get contentBuilder => _rxContentBuilder.distinct();

  void _init() {
    _initController();
  }

  void _initController() {
    controller = DASModalSheetController(
      onClose: () => _rxOpenModalType.add(null),
    );
  }

  /// Opens [builder] in the modal sheet. If the same content (same type and [contentKey]) is already
  /// displayed, the modal is closed instead, so that tapping the element that opened it again toggles it
  /// closed. [contentKey] should identify the concrete content shown.
  void open(DASModalSheetBuilder builder, {bool maximize = false, Object? contentKey}) {
    final type = _typeOf(builder);

    if (isModalOpenValue && openModalTypeValue == type && _openContentKey == contentKey) {
      close();
      return;
    }

    _openContentKey = contentKey;
    _rxOpenModalType.add(type);
    _rxContentBuilder.add(builder);
    if (maximize) {
      controller.maximize();
    } else {
      controller.expand();
    }
  }

  void setMaximized(bool maximized) {
    if (maximized) {
      controller.maximize();
    } else {
      controller.expand();
    }
  }

  DetailModalType _typeOf(DASModalSheetBuilder builder) {
    return switch (builder) {
      AdditionalSpeedRestrictionModalBuilder() => .additionalSpeedRestriction,
      ServicePointModalBuilder() => .servicePointModal,
      BrakeLoadSlipModalBuilder() => .brakeSlip,
      _ => throw ArgumentError('Unknown DASModalSheetBuilder: ${builder.runtimeType}'),
    };
  }

  void close() {
    controller.close();
    _rxContentBuilder.add(null);
    _openContentKey = null;
  }

  void dispose() {
    controller.dispose();
    _rxOpenModalType.close();
    _rxContentBuilder.close();
  }
}

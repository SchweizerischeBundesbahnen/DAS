import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_builder.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_builder.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:rxdart/rxdart.dart';

enum DetailModalType { servicePointModal, additionalSpeedRestriction, brakeSlip }

abstract class ModalViewModel {
  DASModalSheetController? get controller;
  bool get isModalOpenValue;
  Stream<DetailModalType?> get openModalType;
  DetailModalType? get openModalTypeValue;
  Stream<bool> get isModalOpen;
  Stream<DASModalSheetBuilder?> get contentBuilder;

  void open(DASModalSheetBuilder builder, {bool maximize = false, Object? contentKey});
  void setMaximized(bool maximized);
  void close();
  void dispose();
}

class DetailModalViewModel() extends ModalViewModel {
  this {
    _init();
  }

  late DASModalSheetController _controller;

  final _rxContentBuilder = BehaviorSubject<DASModalSheetBuilder?>();
  final _rxOpenModalType = BehaviorSubject<DetailModalType?>.seeded(null);

  /// Identifies which concrete content of [openModalTypeValue] is currently displayed (e.g. the tapped
  /// service point + tab, or the tapped ASR row). Re-opening with the same type and key closes the modal.
  Object? _openContentKey;

  @override
  DASModalSheetController get controller => _controller;

  @override
  bool get isModalOpenValue => _rxOpenModalType.value != null;

  @override
  Stream<DetailModalType?> get openModalType => _rxOpenModalType.distinct();

  @override
  DetailModalType? get openModalTypeValue => _rxOpenModalType.value;

  @override
  Stream<bool> get isModalOpen => _rxOpenModalType.map((type) => type != null);

  @override
  Stream<DASModalSheetBuilder?> get contentBuilder => _rxContentBuilder.distinct();

  void _init() {
    _initController();
  }

  void _initController() {
    _controller = DASModalSheetController(
      onClose: () {
        if (!_rxOpenModalType.isClosed) _rxOpenModalType.add(null);
      },
    );
  }

  /// Opens [builder] in the modal sheet. If the same content (same type and [contentKey]) is already
  /// displayed, the modal is closed instead, so that tapping the element that opened it again toggles it
  /// closed. [contentKey] should identify the concrete content shown.
  @override
  void open(DASModalSheetBuilder builder, {bool maximize = false, Object? contentKey}) {
    final type = _typeOf(builder);

    if (isModalOpenValue && openModalTypeValue == type && _openContentKey == contentKey) {
      close();
      return;
    }

    _controller.automaticCloseEnabled = builder.automaticCloseEnabled;
    _openContentKey = contentKey;
    _rxOpenModalType.add(type);
    _rxContentBuilder.add(builder);
    if (maximize) {
      _controller.maximize();
    } else {
      _controller.expand();
    }
  }

  @override
  void setMaximized(bool maximized) {
    if (maximized) {
      _controller.maximize();
    } else {
      _controller.expand();
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

  @override
  void close() {
    _controller.close();
    if (!_rxContentBuilder.isClosed) _rxContentBuilder.add(null);
    _openContentKey = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    _rxOpenModalType.close();
    _rxContentBuilder.close();
  }
}

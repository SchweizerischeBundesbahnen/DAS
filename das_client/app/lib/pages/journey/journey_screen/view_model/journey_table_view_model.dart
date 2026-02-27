import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_table_model.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableViewModel');

class JourneyTableViewModel extends JourneyAwareViewModel {
  JourneyTableViewModel({
    required super.journeyViewModel,
    required JourneySettingsViewModel settingsVM,
    required CollapsibleRowsViewModel collapsibleRowsVM,
    required JourneyPositionViewModel positionVM,
    required DetailModalViewModel detailModalVM,
    required DecisiveGradientViewModel decisiveGradientVM,
  }) : _settingsVM = settingsVM,
       _collapsibleRowsVM = collapsibleRowsVM,
       _positionVM = positionVM,
       _detailModalVM = detailModalVM,
       _decisiveGradientVM = decisiveGradientVM {
    _init();
  }

  final JourneySettingsViewModel _settingsVM;
  final CollapsibleRowsViewModel _collapsibleRowsVM;
  final JourneyPositionViewModel _positionVM;
  final DetailModalViewModel _detailModalVM;
  final DecisiveGradientViewModel _decisiveGradientVM;

  late StreamSubscription<
    (
      Journey?,
      JourneySettings,
      Map<int, CollapsedState>,
      JourneyPositionModel,
      DetailModalType?,
      bool,
    )
  >?
  _streamSubscription;

  final _rxModel = BehaviorSubject<JourneyTableModel>.seeded(TableLoading());

  Stream<JourneyTableModel> get model => _rxModel.stream.distinct();

  JourneyTableModel get modelValue => _rxModel.value;

  @override
  void journeyIdentificationChanged(Journey? journey) {
    _emitLoading();
    _init();
  }

  void _init() {
    _streamSubscription?.cancel();
    _streamSubscription =
        CombineLatestStream.combine6(
          journeyViewModel.journey,
          _settingsVM.model,
          _collapsibleRowsVM.collapsedRows,
          _positionVM.model,
          _detailModalVM.openModalType,
          _decisiveGradientVM.showDecisiveGradient,
          (a, b, c, d, e, f) => (a, b, c, d, e, f),
        ).listen(
          (data) => _handleDataChanged(
            journey: data.$1,
            settings: data.$2,
            collapsibleRows: data.$3,
            position: data.$4,
            detailModalType: data.$5,
            showDecisiveGradient: data.$6,
          ),
        );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _rxModel.close();
    super.dispose();
  }

  void _handleDataChanged({
    required JourneySettings settings,
    required Map<int, CollapsedState> collapsibleRows,
    required JourneyPositionModel position,
    required bool showDecisiveGradient,
    DetailModalType? detailModalType,
    Journey? journey,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }
  }

  void _emitLoading() {
    _log.fine('Emitting TableLoading.');
    _rxModel.add(TableLoading());
  }
}

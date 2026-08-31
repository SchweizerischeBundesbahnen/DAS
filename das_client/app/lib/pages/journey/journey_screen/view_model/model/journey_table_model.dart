import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

sealed class JourneyTableModel {
  JourneyTableModel._();
}

class TableLoading() extends JourneyTableModel {
  this : super._();

  @override
  String toString() {
    return 'TableLoading{}';
  }
}

class TableLoaded({
  required final List<BaseData> journeyTableRowData,
  required final Metadata journeyMetadata,
  required final JourneySettings journeySettings,
  required final Map<int, CollapsedState> collapsedRows,
  required final JourneyPositionModel journeyPosition,
  required final ChevronPositionModel chevronPosition,
  final DetailModalType? detailModalType,
  final bool? showDecisiveGradient,
}) extends JourneyTableModel {
  this : super._();

  @override
  String toString() {
    return 'TableLoaded{journeyTableRowData: $journeyTableRowData'
        ', journeyMetadata: $journeyMetadata'
        ', journeySettings: $journeySettings'
        ', collapsedRows: $collapsedRows'
        ', journeyPosition: $journeyPosition'
        ', chevronPosition: $chevronPosition'
        ', detailModalType: $detailModalType'
        ', showDecisiveGradient: $showDecisiveGradient'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLoaded &&
          runtimeType == other.runtimeType &&
          journeyTableRowData == other.journeyTableRowData &&
          journeyMetadata == other.journeyMetadata &&
          journeySettings == other.journeySettings &&
          collapsedRows == other.collapsedRows &&
          journeyPosition == other.journeyPosition &&
          chevronPosition == other.chevronPosition &&
          detailModalType == other.detailModalType &&
          showDecisiveGradient == other.showDecisiveGradient;

  @override
  int get hashCode => Object.hash(
    journeyTableRowData,
    journeyMetadata,
    journeySettings,
    collapsedRows,
    journeyPosition,
    chevronPosition,
    detailModalType,
    showDecisiveGradient,
  );
}

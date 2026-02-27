import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/journey_position_model.dart';
import 'package:app/pages/journey/view_model/model/journey_settings.dart';
import 'package:sfera/component.dart';

sealed class JourneyTableModel {
  JourneyTableModel._();
}

class TableLoading extends JourneyTableModel {
  TableLoading() : super._();

  @override
  String toString() {
    return 'TableLoading{}';
  }
}

class TableLoaded extends JourneyTableModel {
  TableLoaded({
    required this.journeyData,
    required this.journeyMetadata,
    required this.journeySettings,
    required this.collapsedRows,
    required this.journeyPosition,
    this.detailModalType,
    this.showDecisiveGradient,
  }) : super._();

  @override
  String toString() {
    return 'TableLoaded{journeyData: $journeyData'
        ', journeyMetadata: $journeyMetadata'
        ', journeySettings: $journeySettings'
        ', collapsedRows: $collapsedRows'
        ', journeyPosition: $journeyPosition'
        ', detailModalType: $detailModalType'
        ', showDecisiveGradient: $showDecisiveGradient'
        '}';
  }

  final List<BaseData> journeyData;
  final Metadata journeyMetadata;
  final JourneySettings journeySettings;
  final Map<int, CollapsedState> collapsedRows;
  final JourneyPositionModel journeyPosition;
  final DetailModalType? detailModalType;
  final bool? showDecisiveGradient;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableLoaded &&
          runtimeType == other.runtimeType &&
          journeyData == other.journeyData &&
          journeyMetadata == other.journeyMetadata &&
          journeySettings == other.journeySettings &&
          collapsedRows == other.collapsedRows &&
          journeyPosition == other.journeyPosition &&
          detailModalType == other.detailModalType &&
          showDecisiveGradient == other.showDecisiveGradient;

  @override
  int get hashCode => Object.hash(
    journeyData,
    journeyMetadata,
    journeySettings,
    collapsedRows,
    journeyPosition,
    detailModalType,
    showDecisiveGradient,
  );
}

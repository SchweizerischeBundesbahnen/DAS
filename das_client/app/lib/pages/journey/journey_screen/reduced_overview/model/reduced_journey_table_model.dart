import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/route_variant.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:core_data/component.dart';
import 'package:sfera/component.dart';

sealed class ReducedJourneyTableModel {
  ReducedJourneyTableModel._();
}

class ReducedTableLoading() extends ReducedJourneyTableModel {
  this : super._();

  @override
  String toString() {
    return 'ReducedTableLoading{}';
  }
}

class ReducedTableLoaded({
  required final Journey journey,
  required final List<BaseData> journeyTableRowData,
  required final Metadata journeyMetadata,
  required final Map<int, RouteVariant> variantsByOrder,
  required final Map<int, CollapsedState> collapsedRows,
  required final JourneyFilterModel? filter,
}) extends ReducedJourneyTableModel {
  this : super._();

  @override
  String toString() {
    return 'ReducedTableLoaded{journey: $journey'
        ', journeyTableRowData: $journeyTableRowData'
        ', journeyMetadata: $journeyMetadata'
        ', variantsByOrder: $variantsByOrder'
        ', collapsedRows: $collapsedRows'
        ', filter: $filter'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReducedTableLoaded &&
          runtimeType == other.runtimeType &&
          journey == other.journey &&
          journeyTableRowData == other.journeyTableRowData &&
          journeyMetadata == other.journeyMetadata &&
          variantsByOrder == other.variantsByOrder &&
          collapsedRows == other.collapsedRows &&
          filter == other.filter;

  @override
  int get hashCode => Object.hash(
    journey,
    journeyTableRowData,
    journeyMetadata,
    variantsByOrder,
    collapsedRows,
    filter,
  );
}

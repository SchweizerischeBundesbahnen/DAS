import 'dart:async';

import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/journey_filter_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/reduced_journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/route_variant.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/journey_filter_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/combined_foot_note_and_indications.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('ReducedOverviewViewModel');

class ReducedOverviewViewModel({
  required final JourneyViewModel _journeyViewModel,
  required final RouteVariantViewModel _routeVariantViewModel,
  required final CollapsibleRowsViewModel _collapsibleRowsViewModel,
  required final JourneyFilterViewModel _journeyFilterViewModel,
}) {
  this {
    _init();
  }

  final _rxModel = BehaviorSubject<ReducedJourneyTableModel>.seeded(ReducedTableLoading());

  Stream<ReducedJourneyTableModel> get model => _rxModel.stream;

  ReducedJourneyTableModel get modelValue => _rxModel.value;

  Stream<JourneyFilterModel?> get filters => _journeyFilterViewModel.model;

  JourneyFilterModel? get filtersValue => _journeyFilterViewModel.modelValue;

  StreamSubscription? _subscription;

  void _init() {
    _subscription =
        CombineLatestStream.combine4(
          _journeyViewModel.journey,
          _routeVariantViewModel.variantsByOrder,
          _collapsibleRowsViewModel.collapsedRows,
          _journeyFilterViewModel.model,
          (journey, variantsByOrder, collapsedRows, filters) => (journey, variantsByOrder, collapsedRows, filters),
        ).listen(
          (data) => _handleDataChanged(
            journey: data.$1,
            variantsByOrder: data.$2,
            collapsedRows: data.$3,
            filter: data.$4,
          ),
          onError: _rxModel.addError,
        );
  }

  void _handleDataChanged({
    required Journey? journey,
    required Map<int, RouteVariant> variantsByOrder,
    required Map<int, CollapsedState> collapsedRows,
    required JourneyFilterModel? filter,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }

    var relevantData = _mandatoryDataForReducedOverview(journey, variantsByOrder);

    if (filter != null) {
      _addFilterData(relevantData, filter);
    }

    relevantData.sort((a1, a2) => a1.compareTo(a2));
    _removeDuplicatedASR(relevantData);

    relevantData = relevantData
        .hideCommunicationNetworkChangesWithSameTypeAsPreviousOrIsServicePoint()
        .hideIndicationsForHiddenServicePoint()
        .combineFootNoteAndIndications()
        .sorted(
          (a1, a2) => a1.compareTo(a2),
        );

    _emitLoaded(
      ReducedTableLoaded(
        journey: journey,
        journeyTableRowData: relevantData,
        journeyMetadata: journey.metadata,
        variantsByOrder: variantsByOrder,
        collapsedRows: collapsedRows,
        filter: filter,
      ),
    );
  }

  void _addFilterData(List<BaseData> baseData, JourneyFilterModel filter) {
    final filterData = filter.getFilteredData();

    for (final entry in filterData) {
      if (!baseData.contains(entry)) baseData.add(entry);
    }
  }

  List<BaseData> _mandatoryDataForReducedOverview(Journey journey, Map<int, RouteVariant> variantsByOrder) {
    return journey.data.where((it) => _relevantForReducedOverview(it, journey.metadata, variantsByOrder)).toList();
  }

  void _removeDuplicatedASR(List<BaseData> data) {
    for (int i = 1; i < data.length; i++) {
      final current = data[i];
      final previous = data[i - 1];
      if (current is AdditionalSpeedRestrictionData && previous is AdditionalSpeedRestrictionData) {
        if (current.restrictions == previous.restrictions) {
          data.removeAt(i);
          i--;
        }
      }
    }
  }

  bool _relevantForReducedOverview(BaseData data, Metadata metadata, Map<int, RouteVariant> variantsByOrder) {
    final isServicePointWithStop = data.dataType == .servicePoint && (data as ServicePoint).isStop;
    final isNetworkChange =
        metadata.communicationNetworkChanges.changeAtOrder(data.order) != null &&
        data.dataType == .communicationNetworkChannel;
    final hasRouteVariantDisplay = data is ServicePoint && variantsByOrder.containsKey(data.order);

    return isServicePointWithStop || isNetworkChange || hasRouteVariantDisplay;
  }

  void _emitLoading() {
    _log.fine('Emitting ReducedTableLoading.');
    _rxModel.add(ReducedTableLoading());
  }

  void _emitLoaded(ReducedTableLoaded model) {
    _log.fine('Emitting ReducedTableLoaded.');
    _rxModel.add(model);
  }

  void dispose() {
    _subscription?.cancel();
    _rxModel.close();
  }
}

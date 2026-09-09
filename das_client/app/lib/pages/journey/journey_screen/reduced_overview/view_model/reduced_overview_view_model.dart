import 'dart:async';

import 'package:app/pages/journey/journey_screen/reduced_overview/model/reduced_journey_table_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/model/route_variant.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/view_model/route_variant_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

final _log = Logger('ReducedOverviewViewModel');

class ReducedOverviewViewModel({
  required final JourneyViewModel _journeyViewModel,
  required final RouteVariantViewModel _routeVariantViewModel,
  required final CollapsibleRowsViewModel _collapsibleRowsViewModel,
}) {
  this {
    _init();
  }

  final _rxModel = BehaviorSubject<ReducedJourneyTableModel>.seeded(ReducedTableLoading());

  Stream<ReducedJourneyTableModel> get model => _rxModel.stream;

  ReducedJourneyTableModel get modelValue => _rxModel.value;

  StreamSubscription<(Journey?, Map<int, RouteVariant>, Map<int, CollapsedState>)>? _subscription;

  void _init() {
    _subscription =
        CombineLatestStream.combine3(
          _journeyViewModel.journey,
          _routeVariantViewModel.variantsByOrder,
          _collapsibleRowsViewModel.collapsedRows,
          (journey, variantsByOrder, collapsedRows) => (journey, variantsByOrder, collapsedRows),
        ).listen(
          (data) => _handleDataChanged(
            journey: data.$1,
            variantsByOrder: data.$2,
            collapsedRows: data.$3,
          ),
          onError: _rxModel.addError,
        );
  }

  void _handleDataChanged({
    required Journey? journey,
    required Map<int, RouteVariant> variantsByOrder,
    required Map<int, CollapsedState> collapsedRows,
  }) {
    if (journey == null) {
      _emitLoading();
      return;
    }

    final relevantData = _relevantDataForReducedOverview(journey);
    _emitLoaded(
      ReducedTableLoaded(
        journey: journey,
        journeyTableRowData: relevantData,
        journeyMetadata: journey.metadata,
        variantsByOrder: variantsByOrder,
        collapsedRows: collapsedRows,
      ),
    );
  }

  List<BaseData> _relevantDataForReducedOverview(Journey journey) {
    final relevantData = journey.data.where((it) => _relevantForReducedOverview(it, journey.metadata)).toList();
    _removeDuplicatedASR(relevantData);
    return relevantData;
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

  bool _relevantForReducedOverview(BaseData data, Metadata metadata) {
    final isServicePointWithStop = data.dataType == .servicePoint && (data as ServicePoint).isStop;
    final isNetworkChange =
        metadata.communicationNetworkChanges.changeAtOrder(data.order) != null &&
        data.dataType == .communicationNetworkChannel;
    final isIndication = data.dataType == .ruIndication || data.dataType == .operationalIndication;

    return isServicePointWithStop ||
        isNetworkChange ||
        isIndication ||
        data.dataType == .additionalSpeedRestriction ||
        _isServicePointWithPassToStopOrStopToPassChange(data, metadata) ||
        _hasModification(data);
  }

  bool _isServicePointWithPassToStopOrStopToPassChange(BaseData data, Metadata metadata) =>
      data is ServicePoint &&
      metadata.shortTermChanges
          .appliesToOrder(data.order)
          .where((it) => it is PassToStopChange || it is StopToPassChange)
          .isNotEmpty;

  bool _hasModification(BaseData data) =>
      (data is JourneyPoint && (data.hasModificationUpdated || (data.isDeleted && !data.shouldHide)));

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

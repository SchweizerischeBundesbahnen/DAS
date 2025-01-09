import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/model/train_journey_settings.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/break_series_selection.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/balise_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_render_data.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/connection_track_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/level_crossing_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/speed_change_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/tram_area_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/whistle_row.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  static const Key breakingSeriesHeaderKey = Key('breaking_series_header_key');

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([bloc.journeyStream, bloc.settingsStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?[0] == null) {
          return Container();
        }

        final journey = snapshot.data![0] as Journey;
        final settings = snapshot.data![1] as TrainJourneySettings;

        return _body(context, journey, settings);
      },
    );
  }

  Widget _body(BuildContext context, Journey journey, TrainJourneySettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: DASTable(
        columns: _columns(context, journey, settings),
        rows: _rows(context, journey, settings),
      ),
    );
  }

  List<DASTableRow> _rows(BuildContext context, Journey journey, TrainJourneySettings settings) {
    return List.generate(journey.data.length, (index) {
      final rowData = journey.data[index];

      final renderData = TrackEquipmentRenderData.from(journey, index);
      switch (rowData.type) {
        case Datatype.servicePoint:
          return ServicePointRow(
                  metadata: journey.metadata,
                  data: rowData as ServicePoint,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.protectionSection:
          return ProtectionSectionRow(
                  metadata: journey.metadata,
                  data: rowData as ProtectionSection,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.curvePoint:
          return CurvePointRow(
                  metadata: journey.metadata,
                  data: rowData as CurvePoint,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.signal:
          return SignalRow(
                  metadata: journey.metadata,
                  data: rowData as Signal,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
                  metadata: journey.metadata,
                  data: rowData as AdditionalSpeedRestrictionData,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.connectionTrack:
          return ConnectionTrackRow(
                  metadata: journey.metadata,
                  data: rowData as ConnectionTrack,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.speedChange:
          return SpeedChangeRow(
                  metadata: journey.metadata,
                  data: rowData as SpeedChange,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.cabSignaling:
          return CABSignalingRow(
                  metadata: journey.metadata,
                  data: rowData as CABSignaling,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.balise:
          return BaliseRow(
                  metadata: journey.metadata,
                  data: rowData as Balise,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.whistle:
          return WhistleRow(
                  metadata: journey.metadata,
                  data: rowData as Whistle,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.levelCrossing:
          return LevelCrossingRow(
                  metadata: journey.metadata,
                  data: rowData as LevelCrossing,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
        case Datatype.tramArea:
          return TramAreaRow(
                  metadata: journey.metadata,
                  data: rowData as TramArea,
                  settings: settings,
                  trackEquipmentRenderData: renderData)
              .build(context);
      }
    });
  }

  List<DASTableColumn> _columns(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final speedLabel = settings.selectedBreakSeries != null
        ? '${settings.selectedBreakSeries!.trainSeries.name}${settings.selectedBreakSeries!.breakSeries}'
        : '${journey.metadata.breakSeries?.trainSeries.name ?? '?'}${journey.metadata.breakSeries?.breakSeries ?? '?'}';

    return [
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_kilometre_label), width: 64.0),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_time_label), width: 100.0),
      DASTableColumn(width: 48.0), // route column
      DASTableColumn(width: 20.0), // track equipment column
      DASTableColumn(width: 64.0), // icons column
      DASTableColumn(
        child: Text(context.l10n.p_train_journey_table_journey_information_label),
        expanded: true,
        alignment: Alignment.centerLeft,
      ),
      DASTableColumn(width: 68.0), // icons column
      DASTableColumn(width: 48.0), // icons column
      DASTableColumn(
        child: Text(context.l10n.p_train_journey_table_graduated_speed_label),
        width: 100.0,
        border: BorderDirectional(
          bottom: BorderSide(color: SBBColors.cloud, width: 1.0),
          end: BorderSide(color: SBBColors.cloud, width: 2.0),
        ),
      ),
      // TODO: find out what to do when break series is not defined
      DASTableColumn(
          child: Text(speedLabel),
          width: 62.0,
          onTap: () => _onBreakSeriesTap(context, journey, settings),
          headerKey: breakingSeriesHeaderKey),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_advised_speed_label), width: 62.0),
      DASTableColumn(width: 40.0), // actions
    ];
  }

  void _onBreakSeriesTap(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final trainJourneyCubit = context.trainJourneyCubit;

    showSBBModalSheet<BreakSeries>(
            context: context,
            title: context.l10n.p_train_journey_break_series,
            constraints: BoxConstraints(),
            child: BreakSeriesSelection(
                availableBreakSeries: journey.metadata.availableBreakSeries,
                selectedBreakSeries: settings.selectedBreakSeries ?? journey.metadata.breakSeries))
        .then(
      (newValue) => {
        if (newValue != null) {trainJourneyCubit.updateBreakSeries(newValue)}
      },
    );
  }
}

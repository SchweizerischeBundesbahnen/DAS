import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/model/train_journey_settings.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/break_series_selection.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/connection_track_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/speed_change_row.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

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

      switch (rowData.type) {
        case Datatype.servicePoint:
          return ServicePointRow(metadata: journey.metadata, data: rowData as ServicePoint, settings: settings)
              .build(context);
        case Datatype.protectionSection:
          return ProtectionSectionRow(
                  metadata: journey.metadata, data: rowData as ProtectionSection, settings: settings)
              .build(context);
        case Datatype.curvePoint:
          return CurvePointRow(metadata: journey.metadata, data: rowData as CurvePoint, settings: settings)
              .build(context);
        case Datatype.signal:
          return SignalRow(metadata: journey.metadata, data: rowData as Signal, settings: settings).build(context);
        case Datatype.additionalSpeedRestriction:
          return AdditionalSpeedRestrictionRow(
                  metadata: journey.metadata, data: rowData as AdditionalSpeedRestrictionData, settings: settings)
              .build(context);
        case Datatype.connectionTrack:
          return ConnectionTrackRow(metadata: journey.metadata, data: rowData as ConnectionTrack, settings: settings)
              .build(context);
        case Datatype.speedChange:
          return SpeedChangeRow(metadata: journey.metadata, data: rowData as SpeedChange, settings: settings)
              .build(context);
        case Datatype.cabSignaling:
          return CABSignalingRow(metadata: journey.metadata, data: rowData as CABSignaling, settings: settings)
              .build(context);
      }
    });
  }

  List<DASTableColumn> _columns(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final speedLabel = settings.selectedBreakSeries != null
        ? '${settings.selectedBreakSeries!.trainSeries.name}${settings.selectedBreakSeries!.breakSeries}'
        : '${journey.metadata.trainSeries.name}${journey.metadata.breakSeries}';

    return [
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_kilometre_label), width: 64.0),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_time_label), width: 100.0),
      DASTableColumn(width: 48.0), // route column
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
      DASTableColumn(child: Text(speedLabel), width: 62.0, onTap: () => _onBreakSeriesTap(context, journey, settings)),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_advised_speed_label), width: 62.0),
      DASTableColumn(width: 40.0), // actions
    ];
  }

  void _onBreakSeriesTap(BuildContext context, Journey journey, TrainJourneySettings settings) {
    final trainJourneyCubit = context.trainJourneyCubit;

    final selectedBreakSeries = BreakSeries(
      trainSeries: settings.selectedBreakSeries?.trainSeries ?? journey.metadata.trainSeries,
      breakSeries: settings.selectedBreakSeries?.breakSeries ?? journey.metadata.breakSeries,
    );

    showSBBModalSheet<BreakSeries>(
            useRootNavigator: false,
            context: context,
            title: context.l10n.p_train_journey_break_series,
            child: BreakSeriesSelection(
                availableBreakSeries: journey.metadata.availableBreakSeries, selectedBreakSeries: selectedBreakSeries))
        .then(
      (newValue) => {
        if (newValue != null) {trainJourneyCubit.updateBreakSeries(newValue)}
      },
    );
  }
}

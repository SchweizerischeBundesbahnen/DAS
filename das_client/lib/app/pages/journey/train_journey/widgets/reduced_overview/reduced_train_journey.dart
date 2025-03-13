import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/table/reduced_additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/table/reduced_base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/table/reduced_service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/bracket_station_render_data.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_config.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ReducedTrainJourney extends StatelessWidget {
  const ReducedTrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ReducedOverviewViewModel>();
    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([viewModel.journeyData, viewModel.journeyMetadata]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: SBBLoadingIndicator.tiny());
        }

        final data = snapshot.data![0] as List<BaseData>;
        final metadata = snapshot.data![1] as Metadata;

        return _body(context, metadata, data);
      },
    );
  }

  Widget _body(BuildContext context, Metadata metadata, List<BaseData> data) {
    // TODO: Currently has full bottom margin for sticky header. Makes no sense here. Should only scroll so last rows are visible
    return DASTable(
      columns: _columns(context),
      rows: _rows(context, metadata, data).map((it) => it.build(context)).toList(),
    );
  }

  List<ReducedBaseRowBuilder> _rows(BuildContext context, Metadata metadata, List<BaseData> data) {
    final List<ReducedBaseRowBuilder?> builders = List.generate(data.length, (index) {
      final rowData = data[index];
      final trainJourneyConfig = TrainJourneyConfig(
        bracketStationRenderData: BracketStationRenderData.from(rowData, metadata),
      );

      switch (rowData.type) {
        case Datatype.servicePoint:
          return ReducedServicePointRow(
            metadata: metadata,
            data: rowData as ServicePoint,
            config: trainJourneyConfig,
          );
        case Datatype.additionalSpeedRestriction:
          return ReducedAdditionalSpeedRestrictionRow(
            metadata: metadata,
            data: rowData as AdditionalSpeedRestrictionData,
            config: trainJourneyConfig,
          );
        default:
          return null;
      }
    });

    return builders.nonNulls.toList();
  }

  List<DASTableColumn> _columns(BuildContext context) {
    return [
      DASTableColumn(width: 100.0, child: Text(context.l10n.p_train_journey_table_time_label)),
      DASTableColumn(width: 48.0), // route column
      DASTableColumn(width: 0.0), // bracket station column
      DASTableColumn(
        expanded: true,
        alignment: Alignment.centerLeft,
        child: Text(context.l10n.p_train_journey_table_journey_information_label),
      ),
      DASTableColumn(width: 48.0), // icons column
      DASTableColumn(
        width: 100.0,
        border: BorderDirectional(
          bottom: BorderSide(color: SBBColors.cloud, width: 1.0),
          end: BorderSide(color: SBBColors.cloud, width: 2.0),
        ),
      ),
      DASTableColumn(width: 80.0, child: Text(context.l10n.p_train_journey_table_communication_network)),
    ];
  }
}

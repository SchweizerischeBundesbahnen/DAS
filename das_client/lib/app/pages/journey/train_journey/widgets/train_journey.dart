import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<Journey?>(
      stream: bloc.journeyStream,
      builder: (context, snapshot) {
        final Journey? journey = snapshot.data;
        if (journey == null) {
          return Container();
        }

        return _body(context, journey);
      },
    );
  }

  Widget _body(
    BuildContext context,
    Journey journey,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: DASTable(
        columns: _columns(context),
        rows: [
          ...List.generate(journey.data.length, (index) {
            final rowData = journey.data[index];

            switch (rowData.type) {
              case Datatype.servicePoint:
                return ServicePointRow(
                  metadata: journey.metadata,
                  servicePoint: rowData as ServicePoint,
                  isRouteStart: index == 0,
                  isRouteEnd: index == journey.data.length - 1,
                ).build(context);
              case Datatype.protectionSection:
                return ProtectionSectionRow(metadata: journey.metadata, protectionSection: rowData as ProtectionSection)
                    .build(context);
              case Datatype.curvePoint:
                // TODO:
                return BaseRowBuilder().build(context);
              case Datatype.signal:
                // TODO:
                return BaseRowBuilder().build(context);
            }
          })
        ],
      ),
    );
  }

  List<DASTableColumn> _columns(BuildContext context) {
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
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_braked_weight_speed_label), width: 62.0),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_advised_speed_label), width: 62.0),
      DASTableColumn(width: 40.0), // actions
    ];
  }
}

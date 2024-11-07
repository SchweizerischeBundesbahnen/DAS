import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/app/widgets/table/das_table_column.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<List<dynamic>>(
      stream: CombineLatestStream.list([bloc.journeyStream, bloc.segmentStream]),
      builder: (context, snapshot) {
        JourneyProfile? journeyProfile = snapshot.data?[0];
        List<SegmentProfile> segmentProfiles = snapshot.data?[1] ?? [];
        if (journeyProfile == null) {
          return Container();
        }

        return _body(context, journeyProfile, segmentProfiles);
      },
    );
  }

  Widget _body(
    BuildContext context,
    JourneyProfile journeyProfile,
    List<SegmentProfile> segmentProfiles,
  ) {
    final timingPoints = journeyProfile.segmentProfilesLists
        .expand((it) => it.timingPoints.toList().sublist(it == journeyProfile.segmentProfilesLists.first ? 0 : 1))
        .toList();

    final points = segmentProfiles.expand((it) => it.points?.timingPoints.toList() ?? <TimingPoint>[]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: DASTable(
        columns: _columns(context),
        rows: [
          ...List.generate(timingPoints.length, (index) {
            var timingPoint = timingPoints[index];
            var tpId = timingPoint.timingPointReference.children.whereType<TpIdReference>().firstOrNull?.tpId;
            var tp = points.where((point) => point.id == tpId).firstOrNull;

            return ServicePointRow(
              timingPoint: tp,
              timingPointConstraints: timingPoint,
              active: index == 1,
            ).build(context);
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
        // TODO: how is OG called generally
        child: Text(context.l10n.p_train_journey_table_og_label),
        width: 100.0,
        border: BorderDirectional(
          bottom: BorderSide(color: SBBColors.cloud, width: 1.0),
          end: BorderSide(color: SBBColors.cloud, width: 2.0),
        ),
      ),
      // TODO: how is R150 called generally
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_r150_label), width: 62.0),
      DASTableColumn(child: Text(context.l10n.p_train_journey_table_advised_speed_label), width: 62.0),
      DASTableColumn(width: 40.0), // actions
    ];
  }
}

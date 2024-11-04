import 'package:das_client/bloc/train_journey_cubit.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/timing_point.dart';
import 'package:das_client/model/sfera/timing_point_constraints.dart';
import 'package:das_client/model/sfera/tp_id_reference.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.trainJourneyCubit;

    return StreamBuilder<List<dynamic>>(
        stream:
            CombineLatestStream.list([bloc.journeyStream, bloc.segmentStream]),
        builder: (context, snapshot) {
          JourneyProfile? journeyProfile = snapshot.data?[0];
          List<SegmentProfile> segmentProfiles = snapshot.data?[1] ?? [];
          if (journeyProfile == null) {
            return Container();
          }

          return _body(journeyProfile, segmentProfiles);
        });
  }

  Widget _body(
    JourneyProfile journeyProfile,
    List<SegmentProfile> segmentProfiles,
  ) {
    final timingPoints = journeyProfile.segmentProfilesLists
        .expand((it) => it.timingPoints
            .toList()
            .sublist(it == journeyProfile.segmentProfilesLists.first ? 0 : 1))
        .toList();

    final points = segmentProfiles
        .expand((it) => it.points?.timingPoints.toList() ?? <TimingPoint>[]);

    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(timingPoints.length, (index) {
            var timingPoint = timingPoints[index];
            var tpId = timingPoint.timingPointReference.children
                .whereType<TpIdReference>()
                .firstOrNull
                ?.tpId;
            var tp = points.where((point) => point.id == tpId).firstOrNull;
            return Padding(
              padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
              child: Row(
                children: [
                  _arrivalTime(timingPoint),
                  const SizedBox(width: sbbDefaultSpacing),
                  _servicePointName(tp),
                ],
              ),
            );
          })
        ],
      ),
    );
  }

  Widget _servicePointName(TimingPoint? tp) =>
      Text(tp?.names.first.name ?? 'Unknown');

  Widget _arrivalTime(TimingPointConstraints timingPoint) {
    return Text(timingPoint.attributes['TP_PlannedLatestArrivalTime'] ?? '');
  }
}

import 'package:das_client/bloc/fahrbild_cubit.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/timing_point.dart';
import 'package:das_client/model/sfera/tp_id_reference.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.fahrbildCubit;

    return StreamBuilder<List<dynamic>>(
        stream: CombineLatestStream.list([bloc.journeyStream, bloc.segmentStream]),
        builder: (context, snapshot) {
          JourneyProfile? journeyProfile = snapshot.data?[0];
          List<SegmentProfile> segmentProfiles = snapshot.data?[1] ?? [];
          if (journeyProfile == null) {
            return Container();
          }

          var timingPoints = journeyProfile.segmentProfilesLists
              .expand((it) => it.timingPoints.toList().sublist(it == journeyProfile.segmentProfilesLists.first ? 0 : 1))
              .toList();
          var points = segmentProfiles.expand((it) => it.points?.timingPoints.toList() ?? <TimingPoint>[]);

          return SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(timingPoints.length, (index) {
                  var timingPoint = timingPoints[index];
                  var tpId = timingPoint.timingPointReference.children.whereType<TpIdReference>().firstOrNull?.tpId;
                  var tp = points.where((point) => point.id == tpId).firstOrNull;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(timingPoint.attributes['TP_PlannedLatestArrivalTime'] ?? ''),
                        const SizedBox(
                          width: sbbDefaultSpacing,
                        ),
                        Text(tp?.names.first.name ?? 'unkown'),
                      ],
                    ),
                  );
                })
              ],
            ),
          );
        });
  }
}

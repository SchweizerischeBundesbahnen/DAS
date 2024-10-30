import 'package:das_client/bloc/fahrbild_cubit.dart';
import 'package:das_client/model/sfera/journey_profile.dart';
import 'package:das_client/model/sfera/segment_profile.dart';
import 'package:das_client/model/sfera/timing_point.dart';
import 'package:das_client/model/sfera/timing_point_constraints.dart';
import 'package:das_client/model/sfera/tp_id_reference.dart';
import 'package:das_client/pages/fahrt/fahrbild/widgets/table/fahrbild_table.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

// CAUTION: ugly code, just for testing!!
class TrainJourney extends StatelessWidget {
  const TrainJourney({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.fahrbildCubit;

    return StreamBuilder<List<dynamic>>(
        stream:
            CombineLatestStream.list([bloc.journeyStream, bloc.segmentStream]),
        builder: (context, snapshot) {
          JourneyProfile? journeyProfile = snapshot.data?[0];
          List<SegmentProfile> segmentProfiles = snapshot.data?[1] ?? [];
          if (journeyProfile == null) {
            return Container();
          }

          var timingPoints = journeyProfile.segmentProfilesLists
              .expand((it) => it.timingPoints.toList().sublist(
                  it == journeyProfile.segmentProfilesLists.first ? 0 : 1))
              .toList();
          var points = segmentProfiles.expand(
              (it) => it.points?.timingPoints.toList() ?? <TimingPoint>[]);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _fahrbildTable(context, timingPoints, points),
          );
        });
  }

  Widget _fahrbildTable(
    BuildContext context,
    List<TimingPointConstraints> timingPoints,
    Iterable<TimingPoint> points,
  ) {
    return FahrbildTable(
      columns: [
        _dataColumn('', fixedWidth: 10), // Used for height workaround
        _dataColumn('km', fixedWidth: 80, centerLabel: false),
        _dataColumn('an/ab', fixedWidth: 100, centerLabel: false),
        _dataColumn('', fixedWidth: 48), // route line
        _dataColumn('', fixedWidth: 64), // icons
        _dataColumn('Streckeninformation', centerLabel: false),
        _dataColumn('', fixedWidth: 68), // icons
        _dataColumn('', fixedWidth: 48), // icons
        _dataColumn('OG', fixedWidth: 88.0),
        _dataColumn('', fixedWidth: 2), // vertical divider
        _dataColumn('R150', fixedWidth: 60.0),
        _dataColumn('FE', fixedWidth: 60.0),
        _dataColumn('', fixedWidth: 40.0),
      ],
      rows: List.generate(timingPoints.length, (index) {
        var timingPoint = timingPoints[index];
        var tpId = timingPoint.timingPointReference.children
            .whereType<TpIdReference>()
            .firstOrNull
            ?.tpId;
        var tp = points.where((point) => point.id == tpId).firstOrNull;

        return _dataRow(
          context,
          active: index == 1,
          km: '10.2',
          bpName: tp?.attributes['TP_ID'] ?? 'Unknown',
          track: 'E25\nTest\nTest',
          time: _parseTime(timingPoint),
        );
      }),
    );
  }

  DataRow _dataRow(BuildContext context,
      {required String km,
      bool active = false,
      required String bpName,
      String? track,
      bool speedSet = true,
      double height = 164.0,
      String? time}) {
    return DataRow(
      color: active
          ? WidgetStateProperty.all(SBBColors.royal.withOpacity(0.2))
          : null,
      cells: [
        // TODO: doesn't work :(
        DataCell(Container(height: height)),
        DataCell(Text(km)),
        DataCell(
          time != null ? Text(time) : SizedBox.shrink(),
        ),
        DataCell(
          Container(
            height: double.infinity,
            child: Stack(alignment: Alignment.center, children: [
              Visibility(
                child: Container(
                  width: 14.0,
                  height: 14.0,
                  decoration: BoxDecoration(
                    color: SBBColors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                visible: active,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
              ),
              // TODO: Overlapping doesn't work inside row
              Positioned(
                left: 0,
                right: 0,
                top: -5,
                bottom: -5,
                child: VerticalDivider(thickness: 2.0, color: SBBColors.black),
              ),
            ]),
          ),
        ),
        DataCell(SizedBox.shrink()),
        DataCell(
          Row(
            children: [
              Expanded(child: Text(bpName)),
              track != null ? Text(track) : SizedBox.shrink(),
            ],
          ),
          onTap: () => SBBToast.of(context).show(message: '$bpName clicked'),
        ),
        DataCell(SizedBox.shrink()),
        DataCell(SizedBox.shrink()),
        DataCell(speedSet
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('110'),
                  Divider(color: SBBColors.black),
                  Text('140'),
                ],
              )
            : SizedBox.shrink()),
        DataCell(VerticalDivider(thickness: 2.0, color: SBBColors.cloud)),
        DataCell(
          speedSet
              ? Align(child: Text('130'), alignment: Alignment.center)
              : SizedBox.shrink(),
        ),
        DataCell(
          speedSet
              ? Align(child: Text('120'), alignment: Alignment.center)
              : SizedBox.shrink(),
        ),
        DataCell(SizedBox.shrink()),
      ],
    );
  }

  String _parseTime(TimingPointConstraints timingPoint) {
    final dateString = timingPoint.attributes["TP_PlannedLatestArrivalTime"];
    if (dateString == null) {
      return '05:51:00'; // TODO:
    }

    DateTime dateTime = DateTime.parse(dateString);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  DataColumn _dataColumn(
    String label, {
    double? fixedWidth,
    centerLabel = true,
  }) {
    return DataColumn2(
      label: Align(
        child: Text(label, style: SBBTextStyles.smallLight),
        alignment: centerLabel ? Alignment.center : Alignment.centerLeft,
      ),
      fixedWidth: fixedWidth,
    );
  }
}

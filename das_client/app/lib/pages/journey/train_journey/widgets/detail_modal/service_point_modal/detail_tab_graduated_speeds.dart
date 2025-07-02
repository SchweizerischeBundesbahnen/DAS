import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

class DetailTabGraduatedSpeeds extends StatelessWidget {
  static const graduatedSpeedsTabKey = Key('graduatedSpeedsTabKey');

  const DetailTabGraduatedSpeeds({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();

    return StreamBuilder(
      key: graduatedSpeedsTabKey,
      stream: CombineLatestStream.list([viewModel.breakSeries, viewModel.relevantSpeedInfo]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final breakSeries = snapshot.requireData[0] as BreakSeries?;
        final relevantSpeeds = snapshot.requireData[1] as List<Speeds>;

        if (breakSeries == null || relevantSpeeds.isEmpty) {
          return Center(
            child: Text(
              context.l10n.w_service_point_modal_graduated_speed_no_information,
              style: DASTextStyles.mediumRoman,
            ),
          );
        } else {
          final breakSeriesLabel = '${breakSeries.trainSeries.name}${breakSeries.breakSeries}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.w_service_point_modal_graduated_speed_break_series_title}: $breakSeriesLabel',
                style: DASTextStyles.smallBold,
              ),
              Expanded(child: _buildSpeedInfoList(context, relevantSpeeds)),
            ],
          );
        }
      },
    );
  }

  Widget _buildSpeedInfoList(BuildContext context, List<Speeds> speedInfo) {
    return ListView.separated(
      physics: ClampingScrollPhysics(),
      itemCount: speedInfo.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final speed = speedInfo[index];
        final incoming = speed.incomingSpeeds.toJoinedString();
        final outgoing = speed.outgoingSpeeds.toJoinedString();
        final hasOutgoing = speed.outgoingSpeeds.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10, right: 16.0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(incoming, style: DASTextStyles.mediumBold),
              const SizedBox(height: 10),
              Text(speed.text!, style: DASTextStyles.mediumRoman),
              const SizedBox(height: 10),

              if (hasOutgoing) ...[
                const Divider(),
                const SizedBox(height: 10),
                Text(outgoing, style: DASTextStyles.mediumBold),
                const SizedBox(height: 10),
                Text(speed.text!, style: DASTextStyles.mediumRoman),
              ],
            ],
          ),
        );
      },
    );
  }
}

extension _SpeedIterableX on Iterable<Speed> {
  String toJoinedString({String divider = '-'}) => map((it) => it.speed).join(divider);
}

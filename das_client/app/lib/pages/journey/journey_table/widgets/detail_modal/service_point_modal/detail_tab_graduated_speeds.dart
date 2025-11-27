import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DetailTabGraduatedSpeeds extends StatelessWidget {
  static const graduatedSpeedsTabKey = Key('graduatedSpeedsTabKey');

  const DetailTabGraduatedSpeeds({super.key = graduatedSpeedsTabKey});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();

    return StreamBuilder(
      stream: CombineLatestStream.list([viewModel.breakSeries, viewModel.relevantSpeedInfo]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loading();

        final breakSeries = snapshot.requireData[0] as BreakSeries?;
        final relevantSpeeds = snapshot.requireData[1] as List<TrainSeriesSpeed>;

        if (breakSeries == null || relevantSpeeds.isEmpty) return _emptyInformation(context);

        return Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .start,
          children: [
            Text(
              '${context.l10n.w_service_point_modal_graduated_speed_break_series_title}: ${breakSeries.name}',
              style: DASTextStyles.smallBold,
            ),
            Expanded(child: _buildSpeedInfoList(context, relevantSpeeds)),
          ],
        );
      },
    );
  }

  Widget _emptyInformation(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.w_service_point_modal_graduated_speed_no_information,
        style: DASTextStyles.mediumRoman,
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSpeedInfoList(BuildContext context, List<TrainSeriesSpeed> speedInfo) {
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      itemCount: speedInfo.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final speed = speedInfo[index];

        return Padding(
          padding: const .symmetric(horizontal: sbbDefaultSpacing, vertical: 10),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              SpeedDisplay(
                speed: speed.speed,
                singleLine: true,
                textStyle: DASTextStyles.mediumBold,
              ),
              const SizedBox(height: 10),
              Text(speed.text!, style: DASTextStyles.mediumRoman),
            ],
          ),
        );
      },
    );
  }
}

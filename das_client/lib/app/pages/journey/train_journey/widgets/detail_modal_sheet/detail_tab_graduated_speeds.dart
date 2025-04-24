import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/break_series.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/speeds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

class DetailTabGraduatedSpeeds extends StatelessWidget {
  static const graduatedSpeedsTabKey = Key('graduatedSpeedsTabKey');

  const DetailTabGraduatedSpeeds({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalSheetViewModel>();
    final journeyCubit = context.trainJourneyCubit;

    return StreamBuilder(
      key: graduatedSpeedsTabKey,
      stream:
          CombineLatestStream.list([journeyCubit.journeyStream, journeyCubit.settingsStream, viewModel.servicePoint]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final journey = snapshot.requireData[0] as Journey?;
        final settings = snapshot.requireData[1] as TrainJourneySettings;
        final servicePoint = snapshot.requireData[2] as ServicePoint?;

        final currentBreakSeries = settings.resolvedBreakSeries(journey?.metadata);
        final relevantSpeeds = servicePoint?.relevantGraduatedSpeedInfo(currentBreakSeries);

        if (currentBreakSeries == null || relevantSpeeds == null || relevantSpeeds.isEmpty) {
          return Center(
            child: Text(
              context.l10n.w_detail_modal_sheet_graduated_speed_no_information,
              style: DASTextStyles.mediumRoman,
            ),
          );
        } else {
          final breakSeriesLabel = '${currentBreakSeries.trainSeries.name}${currentBreakSeries.breakSeries}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.w_detail_modal_sheet_graduated_speed_break_series_title} $breakSeriesLabel',
                style: DASTextStyles.smallBold,
              ),
              Expanded(child: _buildSpeedInfoList(context, relevantSpeeds, currentBreakSeries)),
            ],
          );
        }
      },
    );
  }

  Widget _buildSpeedInfoList(BuildContext context, List<Speeds> speedInfo, BreakSeries breakSeries) {
    return ListView.separated(
      physics: ClampingScrollPhysics(),
      itemCount: speedInfo.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final speed = speedInfo[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            speed.text!,
            style: DASTextStyles.mediumRoman,
          ),
        );
      },
    );
  }
}

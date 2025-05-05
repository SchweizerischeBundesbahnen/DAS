import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_train_journey.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/di.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showReducedOverviewModalSheet(BuildContext context) async {
  final cubit = DI.get<TrainJourneyCubit>();
  final state = cubit.state;
  if (state is TrainJourneyLoadedState) {
    showSBBModalSheet(
      context: context,
      title: context.l10n.w_reduced_train_journey_title,
      constraints: BoxConstraints(),
      child: Provider(
        create: (_) => ReducedOverviewViewModel(
          sferaLocalService: DI.get(),
          trainIdentification: state.trainIdentification,
        ),
        dispose: (context, vm) => vm.dispose(),
        builder: (context, child) => _ReducedOverviewModalSheet(),
      ),
    );
  }
}

class _ReducedOverviewModalSheet extends StatelessWidget {
  const _ReducedOverviewModalSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        spacing: sbbDefaultSpacing * 0.5,
        children: [
          _header(context),
          Expanded(child: ReducedTrainJourney()),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final trainIdentification = context.read<ReducedOverviewViewModel>().trainIdentification;
    return SBBGroup(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: sbbDefaultSpacing),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(Format.dateWithAbbreviatedDay(trainIdentification.date, locale), style: DASTextStyles.largeRoman),
          Spacer(),
          Text(
            '${trainIdentification.trainNumber} ${trainIdentification.ru.displayText(context)}',
            style: DASTextStyles.mediumRoman.copyWith(
              color: ThemeUtil.getColor(
                context,
                SBBColors.granite,
                SBBColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

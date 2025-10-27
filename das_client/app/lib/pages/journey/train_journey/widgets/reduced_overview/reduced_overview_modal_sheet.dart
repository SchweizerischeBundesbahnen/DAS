import 'package:app/di/di.dart';
import 'package:app/extension/journey_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_train_journey.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

Future<void> showReducedOverviewModalSheet(BuildContext context) async {
  final viewModel = DI.get<TrainJourneyViewModel>();
  final trainIdentification = viewModel.journeyValue?.metadata.trainIdentification;
  if (trainIdentification == null) return;

  return showSBBModalSheet(
    context: context,
    title: context.l10n.w_reduced_train_journey_title,
    constraints: BoxConstraints(),
    child: Provider(
      create: (_) => ReducedOverviewViewModel(
        sferaLocalService: DI.get(),
        trainIdentification: trainIdentification,
      ),
      dispose: (context, vm) => vm.dispose(),
      builder: (context, child) => _ReducedOverviewModalSheet(),
    ),
  );
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
    return StreamBuilder(
      stream: context.read<ReducedOverviewViewModel>().journey,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final journey = snapshot.requireData;
        return SBBGroup(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: sbbDefaultSpacing),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(_formattedJourneyDate(context, journey), style: DASTextStyles.largeRoman),
              Spacer(),
              Text(
                journey.formattedTrainIdentifier(context),
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
      },
    );
  }

  String _formattedJourneyDate(BuildContext context, Journey journey) {
    final trainIdentification = journey.metadata.trainIdentification;
    if (trainIdentification == null) return context.l10n.c_unknown;

    final locale = Localizations.localeOf(context);
    return Format.dateWithAbbreviatedDay(trainIdentification.date, locale);
  }
}

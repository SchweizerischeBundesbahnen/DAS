import 'package:app/di/di.dart';
import 'package:app/extension/journey_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/reduced_overview_view_model.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/reduced_journey_table.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

Future<void> showReducedOverviewModalSheet(BuildContext context) async {
  final viewModel = DI.get<JourneyTableViewModel>();
  final trainIdentification = viewModel.journeyValue?.metadata.trainIdentification;
  if (trainIdentification == null) return;

  return showSBBModalSheet(
    context: context,
    title: context.l10n.w_reduced_journey_table_title,
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
      padding: const .symmetric(horizontal: SBBSpacing.medium),
      child: Column(
        mainAxisSize: .max,
        spacing: SBBSpacing.xSmall,
        children: [
          _header(context),
          Expanded(child: ReducedJourneyTable()),
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
        return SBBContentBox(
          padding: const .symmetric(vertical: 20.0, horizontal: SBBSpacing.medium),
          child: Row(
            mainAxisSize: .max,
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

import 'package:app/di/di.dart';
import 'package:app/extension/journey_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyIdentifier extends StatelessWidget {
  const JourneyIdentifier({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: viewModel.journey,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final journey = snapshot.requireData;
        final formattedIdentifier = journey?.formattedTrainIdentifier(context) ?? context.l10n.c_unknown;
        return Padding(
          padding: const EdgeInsets.only(left: sbbDefaultSpacing * 0.5),
          child: Text(formattedIdentifier, style: _resolvedTextStyle(context)),
        );
      },
    );
  }

  TextStyle _resolvedTextStyle(BuildContext context) {
    final resolvedColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
    return DASTextStyles.largeRoman.copyWith(color: resolvedColor);
  }
}

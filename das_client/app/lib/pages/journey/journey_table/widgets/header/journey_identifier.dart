import 'package:app/di/di.dart';
import 'package:app/extension/journey_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/header/journey_search_overlay.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyIdentifier extends StatelessWidget {
  static const Key journeyIdentifierKey = Key('journeyIdentifier');

  const JourneyIdentifier({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneyTableViewModel>();
    return StreamBuilder(
      stream: viewModel.journey,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final journey = snapshot.requireData;
        final formattedIdentifier = journey?.formattedTrainIdentifier(context) ?? context.l10n.c_unknown;
        return JourneySearchOverlay(
          child: Padding(
            key: journeyIdentifierKey,
            padding: const .symmetric(vertical: sbbDefaultSpacing * 0.5, horizontal: 0),
            child: Text(
              formattedIdentifier,
              style: _resolvedTextStyle(context),
              overflow: .ellipsis,
            ),
          ),
        );
      },
    );
  }

  TextStyle _resolvedTextStyle(BuildContext context) {
    final resolvedColor = ThemeUtil.getColor(context, SBBColors.black, SBBColors.graphite);
    return DASTextStyles.xLargeRoman.copyWith(color: resolvedColor);
  }
}

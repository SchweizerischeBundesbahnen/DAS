import 'package:app/di/di.dart';
import 'package:app/extension/ru_extension.dart';
import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyIdentifier extends StatelessWidget {
  const JourneyIdentifier({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneyNavigationViewModel>();

    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final model = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
          child: Text(model.formattedIdentifier(context), style: _resolvedTextStyle(context)),
        );
      },
    );
  }

  TextStyle _resolvedTextStyle(BuildContext context) {
    final resolvedColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
    return DASTextStyles.largeRoman.copyWith(color: resolvedColor);
  }
}

extension _JourneyIdentification on JourneyNavigationModel {
  String formattedIdentifier(BuildContext context) =>
      '${trainIdentification.trainNumber} ${trainIdentification.ru.displayText(context)}';
}

import 'package:app/pages/journey/journey_table/header/departure_authorization/departure_authorization_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DepartureAuthorizationDisplay extends StatelessWidget {
  static const departureAuthorizationIconKey = Key('departureAuthorizationDisplayIcon');
  static const departureAuthorizationTextKey = Key('departureAuthorizationDisplayText');

  const DepartureAuthorizationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: sbbDefaultSpacing * 0.5,
      children: [
        Icon(
          key: departureAuthorizationIconKey,
          SBBIcons.hand_clock_small,
          color: ThemeUtil.getIconColor(context),
        ),
        _departureAuthorization(context),
      ],
    );
  }

  Widget _departureAuthorization(BuildContext context) {
    final viewModel = context.read<DepartureAuthorizationViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final departureAuthText = snapshot.data?.departureAuthText;
        if (departureAuthText == null) return SizedBox.shrink();

        return Text.rich(
          key: departureAuthorizationTextKey,
          TextUtil.parseHtmlText(departureAuthText, DASTextStyles.largeRoman),
        );
      },
    );
  }
}

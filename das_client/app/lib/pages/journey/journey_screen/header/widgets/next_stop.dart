import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/reduced_overview_modal_sheet.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class NextStop extends StatelessWidget {
  static Key get tappableAreaKey => Key('NextStopTappableNextStopIdentifier');

  const NextStop({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: tappableAreaKey,
      onTap: () => showReducedOverviewModalSheet(context),
      child: Row(
        mainAxisSize: .min,
        children: [
          SvgPicture.asset(
            AppAssets.iconHeaderStop,
            colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
          ),
          _servicePointName(context),
        ],
      ),
    );
  }

  Widget _servicePointName(BuildContext context) {
    final viewModel = context.read<JourneyPositionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData) return SizedBox.shrink();
        final model = asyncSnapshot.data!;

        final displayedStop = model.nextStop ?? model.previousStop; // if at last stop, show previous one

        return Padding(
          padding: const .only(left: SBBSpacing.xSmall),
          child: Text(
            displayedStop?.name ?? context.l10n.c_unknown,
            style: sbbTextStyle.boldStyle.xxLarge,
            overflow: .ellipsis,
          ),
        );
      },
    );
  }
}

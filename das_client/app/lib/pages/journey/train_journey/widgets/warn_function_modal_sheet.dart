import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_modal_bottom_sheet.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/di.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showWarnFunctionModalSheet(BuildContext context) => showDASModalSheet(
      context: context,
      backgroundColor: SBBColors.charcoal,
      padding: EdgeInsets.fromLTRB(sbbDefaultSpacing, 64.0, sbbDefaultSpacing, sbbDefaultSpacing * 2),
      child: WarnFunctionModalSheet(),
    );

class WarnFunctionModalSheet extends StatelessWidget {
  const WarnFunctionModalSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: sbbDefaultSpacing * 2,
      children: [
        SvgPicture.asset(AppAssets.imageTypeNSignalStop),
        Container(
          padding: EdgeInsets.all(sbbDefaultSpacing * 0.5),
          color: SBBColors.red125,
          width: double.infinity,
          child: Text(
            context.l10n.w_modal_sheet_warn_function_stop_message,
            textAlign: TextAlign.center,
            style: DASTextStyles.xxLargeBold.copyWith(color: SBBColors.white),
          ),
        ),
        Row(
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            Expanded(
              child: SBBSecondaryButton(
                label: context.l10n.w_modal_sheet_warn_function_manoeuvre_button,
                onPressed: () {
                  DI.get<TrainJourneyCubit>().setManeuverMode(true);
                  Navigator.of(context).pop();
                },
              ),
            ),
            Expanded(
              child: SBBSecondaryButton(
                label: context.l10n.w_modal_sheet_warn_function_confirm_button,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        )
      ],
    );
  }
}

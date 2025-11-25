import 'package:app/i18n/i18n.dart';
import 'package:app/sound/sound.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showWarnFunctionModalSheet(
  BuildContext context, {
  required VoidCallback onManeuverButtonPressed,
}) async {
  await showCustomSBBModalSheet(
    context: context,
    backgroundColor: SBBColors.charcoal,
    showCloseButton: false,
    header: SizedBox.shrink(),
    constraints: const BoxConstraints(maxWidth: double.infinity),
    child: WarnFunctionModalSheet(onManeuverButtonPressed: onManeuverButtonPressed),
  );

  Sound.stop();
}

class WarnFunctionModalSheet extends StatelessWidget {
  static const warnappModalSheetKey = Key('warnappModalSheet');

  const WarnFunctionModalSheet({
    required this.onManeuverButtonPressed,
    super.key,
  });

  final VoidCallback onManeuverButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: warnappModalSheetKey,
      padding: const .fromLTRB(sbbDefaultSpacing, 64.0, sbbDefaultSpacing, sbbDefaultSpacing * 2),
      child: Column(
        mainAxisSize: .min,
        spacing: sbbDefaultSpacing * 2,
        children: [
          SvgPicture.asset(AppAssets.imageTypeNSignalStop),
          Container(
            padding: .all(sbbDefaultSpacing * 0.5),
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
                    onManeuverButtonPressed();
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
          ),
        ],
      ),
    );
  }
}

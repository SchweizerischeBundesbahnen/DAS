import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_modal_bottom_sheet.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

Future<void> showBatteryModalSheet(BuildContext context) => showDASModalSheet(
      context: context,
      backgroundColor: ThemeUtil.getBackgroundColor(context),
      padding: EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, sbbDefaultSpacing, sbbDefaultSpacing * 2),
      child: ShowBatteryModalSheet(),
    );

class ShowBatteryModalSheet extends StatelessWidget {
  const ShowBatteryModalSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SBBIconButtonLarge(
              icon: SBBIcons.cross_medium,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          const SizedBox(height: sbbDefaultSpacing),
          SizedBox(
            width: sbbDefaultSpacing * (15 / 2),
            height: sbbDefaultSpacing * (145 / 16),
            child: SvgPicture.asset(
              AppAssets.staffFemaleLight,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: sbbDefaultSpacing),
          Text(
            context.l10n.w_modal_sheet_battery_status_battery_almost_empty,
            style: DASTextStyles.mediumLight,
          ),
          const SizedBox(height: sbbDefaultSpacing),
          Text(
            context.l10n.w_modal_sheet_battery_status_plug_in_device,
            style: DASTextStyles.smallLight,
          ),
          const SizedBox(height: sbbDefaultSpacing),
        ],
      ),
    );
  }
}

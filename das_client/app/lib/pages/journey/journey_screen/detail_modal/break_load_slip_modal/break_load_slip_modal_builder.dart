import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/break_load_slip/view_model/break_load_slip_view_model.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/break_load_slip_modal/break_load_slip_modal_overview.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipModalBuilder extends DASModalSheetBuilder {
  @override
  Widget header(BuildContext context) {
    return Text(
      context.l10n.w_break_load_slip_modal_title,
      style: DASTextStyles.largeRoman,
    );
  }

  @override
  Widget body(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();
    return StreamBuilder(
      stream: viewModel.formationRun,
      initialData: viewModel.formationRunValue,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        final formationRun = snapshot.requireData!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreakLoadSlipModalOverview(
              formationRunChange: formationRun,
            ),
            SizedBox(height: sbbDefaultSpacing),
            BreakLoadSlipSpecialRestrictions(
              formationRunChange: formationRun,
              groupColor: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight),
              showChangeIndicator: false,
            ),
            SizedBox(height: sbbDefaultSpacing),
            SBBTertiaryButtonLarge(
              label: context.l10n.w_break_load_slip_modal_open_break_slip,
              icon: SBBIcons.link_external_small,
              onPressed: () {
                context.router.push(BreakLoadSlipRoute());
              },
            ),
          ],
        );
      },
    );
  }
}

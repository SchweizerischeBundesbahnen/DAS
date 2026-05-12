import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/brake_load_slip_modal/brake_load_slip_modal_overview.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipModalBuilder extends DASModalSheetBuilder {
  static const headerKey = Key('BrakeLoadSlipModalBuilderHeaderKey');
  static const buttonKey = Key('BrakeLoadSlipModalBuilderButtonKey');

  @override
  Widget header(BuildContext context) {
    return Text(
      key: headerKey,
      context.l10n.w_brake_load_slip_modal_title,
      style: sbbTextStyle.romanStyle.large,
    );
  }

  @override
  Widget body(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();
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
          spacing: SBBSpacing.medium,
          children: [
            BrakeLoadSlipModalOverview(
              formationRunChange: formationRun,
            ),
            BrakeLoadSlipSpecialRestrictions(
              formationRunChange: formationRun,
              groupColor: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight),
              showChangeIndicator: false,
            ),
            SBBTertiaryButton(
              key: buttonKey,
              labelText: context.l10n.w_brake_load_slip_modal_open_brake_slip,
              iconData: SBBIcons.link_external_small,
              onPressed: () {
                context.router.push(BrakeLoadSlipRoute());
              },
            ),
          ],
        );
      },
    );
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_data_row.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_colors.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipSpecialRestrictions extends StatelessWidget {
  const BreakLoadSlipSpecialRestrictions({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      child: Stack(
        children: [
          _specialIndicators(),
          _content(context),
        ],
      ),
    );
  }

  Row _specialIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (formationRun.simTrain) _indicator(AppAssets.iconSimZug, DASColors.simTrain),
        if (formationRun.dangerousGoods) _indicator(AppAssets.iconSignExclamationPoint, SBBColors.peach),
      ],
    );
  }

  Padding _content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing * 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_special_restrictions_title,
            null,
            labelStyle: DASTextStyles.smallBold,
          ),
          SizedBox(height: sbbDefaultSpacing * 0.5),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_special_restrictions_sim_train,
            formationRun.simTrain ? context.l10n.c_yes : context.l10n.c_no,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_special_restrictions_car_carrier,
            formationRun.carCarrierVehicle ? context.l10n.c_yes : context.l10n.c_no,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_special_restrictions_dangerous_goods,
            formationRun.dangerousGoods ? context.l10n.c_yes : context.l10n.c_no,
            valueStyle: formationRun.dangerousGoods ? DASTextStyles.smallBold : null,
          ),
          BreakLoadSlipDataRow(
            context.l10n.p_break_load_slip_special_restrictions_route_class,
            formationRun.routeClass ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _indicator(String asset, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -sbbDefaultSpacing,
            child: SvgPicture.asset(
              AppAssets.shapeRoundedEdgeLeftSmall,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          Container(
            color: color,
            height: 28.0,
            padding: EdgeInsets.only(right: sbbDefaultSpacing * 0.75),
            child: SvgPicture.asset(
              asset,
            ),
          ),
        ],
      ),
    );
  }
}

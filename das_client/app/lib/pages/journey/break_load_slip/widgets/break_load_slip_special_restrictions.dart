import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_colors.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipSpecialRestrictions extends StatelessWidget {
  const BreakLoadSlipSpecialRestrictions({required this.formationRun, super.key});

  static const Key simTrainBannerKey = Key('simTrainBanner');
  static const Key dangerousGoodsBannerKey = Key('dangerousGoodsBanner');
  static const Key carCarrierBannerKey = Key('carCarrierBanner');

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
        if (formationRun.simTrain) _indicator(AppAssets.iconSimZug, DASColors.simTrain, key: simTrainBannerKey),
        if (formationRun.dangerousGoods)
          _indicator(AppAssets.iconSignExclamationPoint, SBBColors.peach, key: dangerousGoodsBannerKey),
        if (formationRun.carCarrierVehicle)
          _indicator(AppAssets.iconCarCarrier, SBBColors.pink, key: carCarrierBannerKey),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow.title(context.l10n.p_break_load_slip_special_restrictions_title),
        SizedBox(height: sbbDefaultSpacing * 0.5),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_sim_train,
          formationRun.simTrain ? context.l10n.c_yes : context.l10n.c_no,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_car_carrier,
          formationRun.carCarrierVehicle ? context.l10n.c_yes : context.l10n.c_no,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_dangerous_goods,
          formationRun.dangerousGoods ? context.l10n.c_yes : context.l10n.c_no,
          valueStyle: formationRun.dangerousGoods ? DASTextStyles.smallBold : null,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_route_class,
          formationRun.routeClass ?? '-',
        ),
      ],
    );
  }

  Widget _indicator(String asset, Color color, {Key? key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(left: sbbDefaultSpacing * 0.25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -sbbDefaultSpacing + 2,
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

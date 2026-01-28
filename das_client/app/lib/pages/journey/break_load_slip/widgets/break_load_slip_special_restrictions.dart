import 'package:app/i18n/i18n.dart';
import 'package:app/theme/das_colors.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/key_value_table.dart';
import 'package:app/widgets/key_value_table_data_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formation/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipSpecialRestrictions extends StatelessWidget {
  const BreakLoadSlipSpecialRestrictions({
    required this.formationRunChange,
    super.key,
    this.groupColor,
    this.showChangeIndicator = true,
  });

  static const Key simTrainBannerKey = Key('simTrainBanner');
  static const Key dangerousGoodsBannerKey = Key('dangerousGoodsBanner');
  static const Key carCarrierBannerKey = Key('carCarrierBanner');

  final FormationRunChange formationRunChange;
  final Color? groupColor;
  final bool showChangeIndicator;

  @override
  Widget build(BuildContext context) {
    return SBBContentBox(
      color: groupColor,
      child: Column(
        children: [
          _headerAndSpecialIndicators(context),
          _content(context),
        ],
      ),
    );
  }

  Row _headerAndSpecialIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(SBBSpacing.xSmall).copyWith(bottom: 0),
            child: _wrappedTitle(context),
          ),
        ),
        if (formationRunChange.formationRun.simTrain)
          _indicator(AppAssets.iconSimZug, DASColors.simTrain, key: simTrainBannerKey),
        if (formationRunChange.formationRun.dangerousGoods)
          _indicator(AppAssets.iconSignExclamationPoint, SBBColors.peach, key: dangerousGoodsBannerKey),
        if (formationRunChange.formationRun.carCarrierVehicle)
          _indicator(AppAssets.iconCarCarrier, SBBColors.pink, key: carCarrierBannerKey),
      ],
    );
  }

  Widget _wrappedTitle(BuildContext context) {
    final titleText = Text(
      context.l10n.p_break_load_slip_special_restrictions_title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: sbbTextStyle.boldStyle.small,
    );

    return showChangeIndicator && _hasChange()
        ? Row(
            children: [
              DotIndicator(
                offset: Offset(0, -SBBSpacing.small),
                child: titleText,
              ),
            ],
          )
        : titleText;
  }

  Widget _content(BuildContext context) {
    return KeyValueTable(
      rows: [
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_sim_train,
          formationRunChange.formationRun.simTrain ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.simTrain),
          showChangeIndicator: showChangeIndicator,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_car_carrier,
          formationRunChange.formationRun.carCarrierVehicle ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.carCarrierVehicle),
          showChangeIndicator: showChangeIndicator,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_dangerous_goods,
          formationRunChange.formationRun.dangerousGoods ? context.l10n.c_yes : context.l10n.c_no,
          hasChange: formationRunChange.hasChanged(.dangerousGoods),
          showChangeIndicator: showChangeIndicator,
        ),
        KeyValueTableDataRow(
          context.l10n.p_break_load_slip_special_restrictions_route_class,
          formationRunChange.formationRun.routeClass ?? '-',
          hasChange: formationRunChange.hasChanged(.routeClass),
          showChangeIndicator: showChangeIndicator,
        ),
      ],
    );
  }

  Widget _indicator(String asset, Color color, {Key? key}) {
    return Padding(
      key: key,
      padding: EdgeInsets.only(left: SBBSpacing.xxSmall),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -SBBSpacing.medium + 2,
            child: SvgPicture.asset(
              AppAssets.shapeRoundedEdgeLeftSmall,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
          Container(
            color: color,
            height: 28.0,
            padding: EdgeInsets.only(right: SBBSpacing.small),
            child: SvgPicture.asset(
              asset,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasChange() {
    return formationRunChange.hasChanged(.simTrain) ||
        formationRunChange.hasChanged(.carCarrierVehicle) ||
        formationRunChange.hasChanged(.dangerousGoods) ||
        formationRunChange.hasChanged(.routeClass);
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_replace_break_series_button.dart';
import 'package:app/theme/das_colors.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHeaderBox extends StatelessWidget {
  static const specialIndicatorBackgroundHeight = 52.0;
  static const specialIndicatorHeight = 38.0;
  static const minHeaderBoxContentHeight = 44.0;

  static const Key simTrainHeaderBannerKey = Key('simTrainHeaderBanner');
  static const Key dangerousGoodsHeaderBannerKey = Key('dangerousGoodsHeaderBanner');
  static const Key carCarrierHeaderBannerKey = Key('carCarrierHeaderBanner');

  const BreakLoadSlipHeaderBox({required this.formationRunChange, super.key});

  final FormationRunChange formationRunChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _specialIndicatorBackground(context),
        Column(
          children: [
            SBBHeaderbox.custom(child: _customHeaderboxContent(context)),
            _specialIndicators(context),
          ],
        ),
      ],
    );
  }

  Widget _customHeaderboxContent(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeaderBoxContentHeight),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          _headerboxTextContent(context),
          BreakLoadSlipReplaceBreakSeriesButton(),
        ],
      ),
    );
  }

  Widget _headerboxTextContent(BuildContext context) {
    final subtitleColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
    final dateChanged = formationRunChange.hasInspectionDateChanged();
    final timeChanged = formationRunChange.hasChanged(.inspectionDateTime);
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text(
          context.l10n.p_break_load_slip_header_title(
            formationRunChange.formationRun.trainCategoryCode ?? '',
            formationRunChange.formationRun.brakedWeightPercentage ?? '',
          ),
          style: sbbTextStyle.boldStyle.medium,
        ),
        Row(
          mainAxisSize: .min,
          children: [
            Text(
              context.l10n.p_break_load_slip_header_subtitle,
              style: sbbTextStyle.lightStyle.small.copyWith(color: subtitleColor),
            ),
            Text(
              DateFormat('dd.MM.yyyy').format(formationRunChange.formationRun.inspectionDateTime),
              style: dateChanged
                  ? sbbTextStyle.boldStyle.small.copyWith(color: subtitleColor)
                  : sbbTextStyle.lightStyle.small.copyWith(color: subtitleColor),
            ),
            Text(
              DateFormat(' HH:mm').format(formationRunChange.formationRun.inspectionDateTime),
              style: timeChanged
                  ? sbbTextStyle.boldStyle.small.copyWith(color: subtitleColor)
                  : sbbTextStyle.lightStyle.small.copyWith(color: subtitleColor),
            ),
          ],
        ),
      ],
    );
  }

  List<_SpecialIndicator> _specialIndicatorsData(BuildContext context) => <_SpecialIndicator>[
    if (formationRunChange.formationRun.simTrain)
      _SpecialIndicator(
        asset: AppAssets.iconSimZug,
        backgroundColor: DASColors.simTrain,
        text: context.l10n.p_break_load_slip_header_sim_train,
        textColor: SBBColors.white,
        key: simTrainHeaderBannerKey,
      ),
    if (formationRunChange.formationRun.dangerousGoods)
      _SpecialIndicator(
        asset: AppAssets.iconSignExclamationPoint,
        backgroundColor: SBBColors.peach,
        text: context.l10n.p_break_load_slip_header_dangerous_goods,
        textColor: SBBColors.black,
        key: dangerousGoodsHeaderBannerKey,
      ),
    if (formationRunChange.formationRun.carCarrierVehicle)
      _SpecialIndicator(
        asset: AppAssets.iconCarCarrier,
        backgroundColor: SBBColors.pink,
        text: context.l10n.p_break_load_slip_header_car_carrier,
        textColor: SBBColors.white,
        key: carCarrierHeaderBannerKey,
      ),
  ];

  Widget _specialIndicatorBackground(BuildContext context) {
    final indicators = _specialIndicatorsData(context);
    if (indicators.isEmpty) return SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: SBBSpacing.xSmall,
      right: SBBSpacing.xSmall,
      child: Row(
        children: indicators.mapIndexed((index, element) {
          return _specialIndicatorBackgroundElement(
            element,
            isFirst: index == 0,
            isLast: index == indicators.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _specialIndicatorBackgroundElement(_SpecialIndicator indicator, {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isFirst)
            Positioned(
              left: -SBBSpacing.small,
              bottom: 0,
              child: SvgPicture.asset(
                AppAssets.shapeRoundedEdgeLeftMedium,
                colorFilter: ColorFilter.mode(indicator.backgroundColor, BlendMode.srcIn),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: indicator.backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: isFirst ? Radius.circular(SBBSpacing.medium) : Radius.zero,
                bottomRight: isLast ? Radius.circular(SBBSpacing.medium) : Radius.zero,
              ),
            ),
            height: specialIndicatorBackgroundHeight,
          ),
        ],
      ),
    );
  }

  Widget _specialIndicators(BuildContext context) {
    final indicators = _specialIndicatorsData(context);
    if (indicators.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall),
      child: Row(
        children: indicators.mapIndexed((index, element) {
          return _specialIndicatorElement(
            element,
            isFirst: index == 0,
          );
        }).toList(),
      ),
    );
  }

  Widget _specialIndicatorElement(_SpecialIndicator specialIndicator, {bool isFirst = false}) {
    return Expanded(
      child: Container(
        key: specialIndicator.key,
        height: specialIndicatorHeight,
        padding: EdgeInsets.only(left: isFirst ? SBBSpacing.medium : SBBSpacing.xxSmall),
        child: Row(
          spacing: SBBSpacing.xSmall,
          children: [
            SvgPicture.asset(specialIndicator.asset),
            Text(
              specialIndicator.text,
              style: sbbTextStyle.lightStyle.small.copyWith(color: specialIndicator.textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialIndicator {
  _SpecialIndicator({
    required this.asset,
    required this.backgroundColor,
    required this.text,
    required this.textColor,
    required this.key,
  });

  final String asset;
  final Color backgroundColor;
  final String text;
  final Color textColor;
  final Key key;
}

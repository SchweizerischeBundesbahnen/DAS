import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_colors.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formation/component.dart';
import 'package:intl/intl.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipHeader extends StatelessWidget {
  static const specialIndicatorBackgroundHeight = 52.0;
  static const specialIndicatorHeight = 38.0;

  const BreakLoadSlipHeader({required this.formationRun, super.key});

  final FormationRun formationRun;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _specialIndicatorBackground(context),
        Column(
          children: [
            SBBHeaderbox(
              title: context.l10n.p_break_load_slip_header_title(
                formationRun.trainCategoryCode ?? '',
                formationRun.brakedWeightPercentage ?? '',
              ),
              secondaryLabel: context.l10n.p_break_load_slip_header_subtitle(
                DateFormat('dd.MM.yyyy HH:mm').format(formationRun.inspectionDateTime),
              ),
            ),
            _specialIndicators(context),
          ],
        ),
      ],
    );
  }

  List<_SpecialIndicators> _specialIndicatorsData(BuildContext context) => <_SpecialIndicators>[
    if (formationRun.simTrain)
      _SpecialIndicators(
        asset: AppAssets.iconSimZug,
        backgroundColor: DASColors.simTrain,
        text: context.l10n.p_break_load_slip_header_sim_train,
        textColor: SBBColors.white,
      ),
    if (formationRun.dangerousGoods)
      _SpecialIndicators(
        asset: AppAssets.iconSignExclamationPoint,
        backgroundColor: SBBColors.peach,
        text: context.l10n.p_break_load_slip_header_dangerous_goods,
        textColor: SBBColors.black,
      ),
  ];

  Widget _specialIndicatorBackground(BuildContext context) {
    final indicators = _specialIndicatorsData(context);
    if (indicators.isEmpty) return SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: sbbDefaultSpacing * 0.5,
      right: sbbDefaultSpacing * 0.5,
      child: Row(
        children: indicators.mapIndexed((index, element) {
          return _specialIndicatorBackgroundElement(
            element,
            index == 0,
            index == indicators.length - 1,
          );
        }).toList(),
      ),
    );
  }

  Widget _specialIndicatorBackgroundElement(_SpecialIndicators indicator, bool isFirst, bool isLast) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isFirst)
            Positioned(
              left: -sbbDefaultSpacing * 0.75,
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
                bottomLeft: isFirst ? Radius.circular(sbbDefaultSpacing) : Radius.zero,
                bottomRight: isLast ? Radius.circular(sbbDefaultSpacing) : Radius.zero,
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
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: Row(
        children: indicators.mapIndexed((index, element) {
          return _specialIndicatorElement(
            element.asset,
            element.backgroundColor,
            element.text,
            element.textColor,
            index == 0,
          );
        }).toList(),
      ),
    );
  }

  Widget _specialIndicatorElement(String asset, Color color, String text, Color textColor, bool isFirst) {
    return Expanded(
      child: Container(
        height: specialIndicatorHeight,
        padding: EdgeInsets.only(left: sbbDefaultSpacing * (isFirst ? 1 : 0.25)),
        child: Row(
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            SvgPicture.asset(
              asset,
            ),
            Text(text, style: DASTextStyles.smallLight.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}

class _SpecialIndicators {
  _SpecialIndicators({required this.asset, required this.backgroundColor, required this.text, required this.textColor});

  final String asset;
  final Color backgroundColor;
  final String text;
  final Color textColor;
}

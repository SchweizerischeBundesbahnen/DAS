import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/switchback_annotation.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SwitchbackRow extends WidgetRowBuilder<SwitchbackAnnotation> {
  SwitchbackRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.routePadding,
    required this.informationPadding,
    super.config,
  }) : super(height: 48.0);

  final double routePadding;
  final double informationPadding;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      height: height,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: SBBSpacing.xSmall),
        padding: EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall),
        decoration: BoxDecoration(color: ThemeUtil.getDASTableColor(context)),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: routePadding),
              child: SizedBox(
                width: informationPadding - routePadding,
                child: SvgPicture.asset(
                  AppAssets.iconUturnTurquoise,
                  colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
                ),
              ),
            ),
            Text(
              context.l10n.w_switchback_row_title,
              style: SBBTextStyles.largeBold,
            ),
          ],
        ),
      ),
    );
  }
}

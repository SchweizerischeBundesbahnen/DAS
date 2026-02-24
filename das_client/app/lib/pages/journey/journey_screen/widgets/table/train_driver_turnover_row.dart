import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TrainDriverTurnoverRow extends WidgetRowBuilder<TrainDriverTurnover> {
  TrainDriverTurnoverRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    super.config,
    super.identifier,
  }) : super(height: 48.0);

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      height: height,
      color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: SBBSpacing.xSmall),
        padding: EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall),
        decoration: BoxDecoration(
          color: ThemeUtil.getDASTableColor(context),
          borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.xSmall)),
        ),
        child: Row(
          spacing: SBBSpacing.xSmall,
          children: [
            SvgPicture.asset(
              AppAssets.iconTrainDriverTurnover,
              colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), BlendMode.srcIn),
            ),
            Text(
              context.l10n.w_train_driver_turnover_row_title,
              style: SBBTextStyles.largeBold,
            ),
          ],
        ),
      ),
    );
  }
}

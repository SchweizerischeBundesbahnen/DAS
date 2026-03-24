import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SuspiciousJourneyPointRow extends WidgetRowBuilder<SuspiciousJourneyPoint> {
  static const rowKey = Key('SuspiciousJourneyPointRow');
  static const firstRowKey = Key('SuspiciousJourneyPointFirstRow');

  SuspiciousJourneyPointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
    required this.isFirst,
    required this.isLast,
  }) : super(height: CellRowBuilder.rowHeight);

  final bool isFirst;
  final bool isLast;

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: rowKey,
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: ThemeUtil.getDASTableColor(context),
        border: isLast ? Border(bottom: BorderSide(color: ThemeUtil.getDASTableBorderColor(context))) : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall),
      alignment: Alignment.bottomLeft,
      child: isFirst
          ? Row(
              key: firstRowKey,
              spacing: SBBSpacing.xSmall,
              children: [
                SvgPicture.asset(
                  AppAssets.iconSignExclamationPoint,
                  colorFilter: ColorFilter.mode(ThemeUtil.getIconColor(context), .srcIn),
                ),
                Text(
                  context.l10n.w_suspicious_journey_point_warning,
                  style: SBBTextStyles.largeBold,
                ),
              ],
            )
          : null,
    );
  }
}

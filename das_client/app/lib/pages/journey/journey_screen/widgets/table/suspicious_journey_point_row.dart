import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/widget_row_builder.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SuspiciousJourneyPointRow extends WidgetRowBuilder<SuspiciousJourneyPoint> {
  static const rowHeight = 220.0; // 5 * standard row height

  SuspiciousJourneyPointRow({
    required super.metadata,
    required super.data,
    required super.rowIndex,
  }) : super(height: rowHeight);

  @override
  Widget buildRowWidget(BuildContext context) {
    return Container(
      key: ValueKey(data.spId),
      width: .infinity,
      height: height,
      decoration: BoxDecoration(
        color: ThemeUtil.getDASTableColor(context),
        border: Border(bottom: BorderSide(color: ThemeUtil.getDASTableBorderColor(context))),
      ),
      padding: .symmetric(horizontal: SBBSpacing.xSmall),
      alignment: .centerLeft,
      child: Row(
        spacing: SBBSpacing.xSmall,
        children: [
          SvgPicture.asset(
            AppAssets.iconSignExclamationPoint,
            colorFilter: .mode(ThemeUtil.getIconColor(context), .srcIn),
          ),
          Text(
            context.l10n.w_suspicious_journey_point_warning,
            style: SBBTextStyles.largeBold,
          ),
        ],
      ),
    );
  }
}

import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BracketStationCellBody extends StatelessWidget {
  static const Key bracketStationKey = Key('bracketStation');
  static const double _bracketStationWidth = 16.0;
  static const double _bracketStationFontSize = 12.0;

  const BracketStationCellBody({
    required this.stationAbbreviation,
    required this.height,
    super.key,
  });

  final String? stationAbbreviation;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tableBorder = DASTableTheme.of(context)?.data.tableBorder;
    final bottomBorder = -(tableBorder?.horizontalInside.width ?? 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          bottom: bottomBorder,
          left: -_bracketStationWidth,
          child: Container(
            key: bracketStationKey,
            height: height,
            width: _bracketStationWidth,
            color: ThemeUtil.getColor(
              context,
              SBBColors.black,
              SBBColors.white,
            ),
            child: Align(
              alignment: Alignment.center,
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  stationAbbreviation ?? '',
                  style: DASTextStyles.extraSmallBold.copyWith(
                    color: ThemeUtil.getFontColor(context),
                    fontSize: _bracketStationFontSize,
                    height: _bracketStationWidth / _bracketStationFontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/bracket_station.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class BracketStationCellBody extends StatelessWidget {
  static const Key bracketStationKey = Key('bracketStationKey');
  static const double _bracketStationWidth = 16.0;
  static const double _bracketStationFontSize = 12.0;

  const BracketStationCellBody({
    required this.bracketStation,
    required this.height,
    super.key,
  });

  final BracketStation bracketStation;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -sbbDefaultSpacing,
      bottom: -sbbDefaultSpacing,
      right: 0,
      child: Container(
        key: bracketStationKey,
        height: height,
        width: _bracketStationWidth,
        color: SBBColors.black,
        child: Align(
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              bracketStation.mainStationAbbreviation ?? '',
              style: DASTextStyles.extraSmallBold.copyWith(
                color: SBBColors.white,
                fontSize: _bracketStationFontSize,
                height: _bracketStationWidth / _bracketStationFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

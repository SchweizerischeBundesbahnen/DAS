import 'package:das_client/model/journey/bracket_station.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class BracketStationBody extends StatelessWidget {
  static const double _bracketStationWidth = 16.0;
  static const double _bracketStationFontSize = 12.0;

  const BracketStationBody({
    super.key,
    required this.bracketStation,
    required this.height
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
        height: height,
        width: _bracketStationWidth,
        color: SBBColors.black,
        child: Align(
          alignment: Alignment.center,
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              bracketStation.mainStationAbbreviation ?? '',
              style: SBBTextStyles.extraSmallBold.copyWith(
                  color: SBBColors.white,
                  fontSize: _bracketStationFontSize,
                  height: _bracketStationWidth / _bracketStationFontSize),
            ),
          ),
        ),
      ),
    );
  }
}

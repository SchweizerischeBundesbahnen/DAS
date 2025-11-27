import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CommunicationNetworkIcon extends StatelessWidget {
  static const Key gsmRKey = Key('gsmPCell');
  static const Key gsmPKey = Key('gsmRCell');

  const CommunicationNetworkIcon({
    required this.networkType,
    super.key,
  });

  final CommunicationNetworkType networkType;

  @override
  Widget build(BuildContext context) {
    final isGsmP = networkType == .gsmP;
    return Container(
      key: isGsmP ? gsmPKey : gsmRKey,
      decoration: BoxDecoration(
        border: Border.all(color: ThemeUtil.getIconColor(context), width: 1.0),
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: .symmetric(horizontal: 15.0),
      child: Text(isGsmP ? 'P' : 'R', style: DASTextStyles.largeRoman),
    );
  }
}

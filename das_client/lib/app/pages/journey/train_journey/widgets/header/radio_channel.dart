import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RadioChannel extends StatelessWidget {
  static const Key gsmRKey = Key('gsmP');
  static const Key gsmPKey = Key('gsmR');

  const RadioChannel({super.key, this.communicationNetworkType});

  final CommunicationNetworkType? communicationNetworkType;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 258.0),
      child: Row(
        spacing: sbbDefaultSpacing * 0.5,
        children: [
          const Icon(SBBIcons.telephone_gsm_small),
          Text('1311', style: DASTextStyles.xLargeRoman),
          if (communicationNetworkType != null) _communicationNetworkIcon()
        ],
      ),
    );
  }

  Widget _communicationNetworkIcon() {
    if (communicationNetworkType == CommunicationNetworkType.sim) {
      return Container();
    }

    final isGsmP = communicationNetworkType == CommunicationNetworkType.gsmP;
    return Container(
      key: isGsmP ? gsmPKey : gsmRKey,
      decoration: BoxDecoration(
        border: Border.all(color: SBBColors.black, width: 1.0),
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Text(isGsmP ? 'P' : 'R', style: DASTextStyles.largeRoman),
    );
  }
}

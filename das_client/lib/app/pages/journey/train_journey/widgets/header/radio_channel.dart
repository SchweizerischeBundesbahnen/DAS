import 'package:das_client/app/pages/journey/train_journey/widgets/header/communication_network_icon.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/radio_contact.dart';
import 'package:das_client/model/journey/communication_network_change.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RadioChannel extends StatelessWidget {
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
          if (communicationNetworkType != null && communicationNetworkType != CommunicationNetworkType.sim)
            CommunicationNetworkIcon(networkType: communicationNetworkType!),
        ],
      ),
    );
  }
}

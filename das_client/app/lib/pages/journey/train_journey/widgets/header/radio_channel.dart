import 'package:app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/radio_contact.dart';
import 'package:app/pages/journey/train_journey/widgets/header/sim_identifier.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class RadioChannel extends StatelessWidget {
  const RadioChannel({required this.metadata, super.key});

  final Metadata metadata;

  @override
  Widget build(BuildContext context) {
    final communicationNetworkType = metadata.currentPosition != null
        ? metadata.communicationNetworkChanges.appliesToOrder(metadata.currentPosition!.order)
        : null;
    final radioContactList = metadata.currentPosition != null
        ? metadata.radioContactLists.lastLowerThan(metadata.currentPosition!.order)
        : null;

    final showIndicator =
        radioContactList != null &&
        (radioContactList.mainContacts.length > 1 || radioContactList.selectiveContacts.isNotEmpty);

    return GestureDetector(
      onTap: () {
        final viewModel = context.read<ServicePointModalViewModel>();
        viewModel.open(context, tab: ServicePointModalTab.communication, servicePoint: metadata.lastServicePoint);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 258.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: DotIndicator(
            show: showIndicator,
            offset: Offset(-6.0, -8.0),
            child: Row(
              spacing: sbbDefaultSpacing * 0.5,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(SBBIcons.telephone_gsm_small),
                RadioContactChannels(contacts: radioContactList),
                if (communicationNetworkType == CommunicationNetworkType.sim) SimIdentifier(),
                if (communicationNetworkType != null && communicationNetworkType != CommunicationNetworkType.sim)
                  CommunicationNetworkIcon(networkType: communicationNetworkType),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

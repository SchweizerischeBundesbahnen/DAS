import 'package:app/app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:app/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:app/app/pages/journey/train_journey/widgets/header/radio_contact.dart';
import 'package:app/app/widgets/indicator_wrapper.dart';
import 'package:app/model/journey/communication_network_change.dart';
import 'package:app/model/journey/contact_list.dart';
import 'package:app/model/journey/metadata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

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

    final showIndicator = radioContactList != null &&
        (radioContactList.mainContacts.length > 1 || radioContactList.selectiveContacts.isNotEmpty);

    return GestureDetector(
      onTap: () {
        final viewModel = context.read<DetailModalSheetViewModel>();
        viewModel.open(tab: DetailModalSheetTab.communication, servicePoint: metadata.nextStop);
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 258.0),
        child: Row(
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            const Icon(SBBIcons.telephone_gsm_small),
            RadioContactChannels(contacts: radioContactList),
            if (communicationNetworkType != null && communicationNetworkType != CommunicationNetworkType.sim)
              IndicatorWrapper(
                  show: showIndicator,
                  offset: Offset(-6.0, -8.0),
                  child: CommunicationNetworkIcon(networkType: communicationNetworkType)),
          ],
        ),
      ),
    );
  }
}

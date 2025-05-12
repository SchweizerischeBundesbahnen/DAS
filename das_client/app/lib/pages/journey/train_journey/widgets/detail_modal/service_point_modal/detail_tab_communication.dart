import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DetailTabCommunication extends StatelessWidget {
  static const communicationTabKey = Key('communicationTab');
  static const radioChannelListKey = Key('communicationTabRadioChannelList');

  const DetailTabCommunication({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: communicationTabKey,
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _communicationNetworkType(context),
            Text(context.l10n.w_detail_modal_sheet_communication_radio_channel, style: DASTextStyles.smallRoman),
            _contactList(context),
          ],
        ),
      ),
    );
  }

  Widget _contactList(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.radioContacts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(context.l10n.w_detail_modal_sheet_communication_radio_channels_not_found),
          );
        }

        final contactList = snapshot.requireData!;
        final contacts = [...contactList.mainContacts, ...contactList.selectiveContacts];
        return ListView.separated(
          key: radioChannelListKey,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) => _contactItem(contacts.elementAt(index)),
        );
      },
    );
  }

  Widget _contactItem(Contact contact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          if (contact.contactRole != null) Text(contact.contactRole!, style: DASTextStyles.mediumRoman),
          Text(contact.contactIdentifier, style: DASTextStyles.mediumBold)
        ],
      ),
    );
  }

  Widget _communicationNetworkType(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.communicationNetworkType,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == CommunicationNetworkType.sim) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.w_detail_modal_sheet_communication_network, style: DASTextStyles.smallRoman),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: sbbDefaultSpacing),
              child: CommunicationNetworkIcon(networkType: snapshot.data!),
            ),
          ],
        );
      },
    );
  }
}

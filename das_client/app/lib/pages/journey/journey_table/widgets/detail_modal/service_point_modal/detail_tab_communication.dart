import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/util/text_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DetailTabCommunication extends StatelessWidget {
  static const communicationTabKey = Key('communicationTab');
  static const radioChannelListKey = Key('communicationTabRadioChannelList');
  static const simCorridorListKey = Key('communicationTabSimCorridorList');
  static const departureAuthorizationKey = Key('communicationTabDepartureAuthorization');

  const DetailTabCommunication({super.key = communicationTabKey});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _departureAuthorization(context),
            _communicationNetworkType(context),
            Text(context.l10n.w_service_point_modal_communication_radio_channel, style: DASTextStyles.smallRoman),
            _contactList(context),
            _simCorridor(context),
          ],
        ),
      ),
    );
  }

  Widget _simCorridor(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.simCorridor,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final contactList = snapshot.requireData!;
        final simContacts = [...contactList.mainContacts, ...contactList.selectiveContacts];
        return ListView.builder(
          key: simCorridorListKey,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: simContacts.length + 1,
          itemBuilder: (context, index) => index == 0
              ? Text(context.l10n.w_service_point_modal_communication_sim, style: DASTextStyles.smallRoman)
              : _simContactItem(simContacts.elementAt(index - 1)),
        );
      },
    );
  }

  Widget _simContactItem(Contact contact) {
    return Padding(
      padding: const .symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 4.0,
        children: [
          SizedBox(width: 60.0, child: Text(contact.contactIdentifier, style: DASTextStyles.smallBold)),
          if (contact.contactRole != null) Expanded(child: Text(contact.contactRole!, style: DASTextStyles.smallRoman)),
        ],
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
            padding: const .symmetric(vertical: 10.0),
            child: Text(context.l10n.w_service_point_modal_communication_radio_channels_not_found),
          );
        }

        final contactList = snapshot.requireData!;
        final contacts = [...contactList.mainContacts, ...contactList.selectiveContacts];
        return ListView.separated(
          key: radioChannelListKey,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          separatorBuilder: (_, _) => Divider(),
          itemBuilder: (context, index) => _contactItem(contacts.elementAt(index)),
        );
      },
    );
  }

  Widget _contactItem(Contact contact) {
    return Padding(
      padding: const .symmetric(horizontal: sbbDefaultSpacing, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4.0,
        children: [
          if (contact.contactRole != null) Text(contact.contactRole!, style: DASTextStyles.mediumRoman),
          Text(contact.contactIdentifier, style: DASTextStyles.mediumBold),
        ],
      ),
    );
  }

  Widget _communicationNetworkType(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.communicationNetworkType,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == .sim) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.w_service_point_modal_communication_network, style: DASTextStyles.smallRoman),
            Padding(
              padding: const .symmetric(vertical: 10.0, horizontal: sbbDefaultSpacing),
              child: CommunicationNetworkIcon(networkType: snapshot.data!),
            ),
          ],
        );
      },
    );
  }

  Widget _departureAuthorization(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.departureAuthorization,
      builder: (context, snapshot) {
        final departureAuthText = snapshot.data?.text;
        if (departureAuthText == null) return SizedBox.shrink();

        return Column(
          key: departureAuthorizationKey,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.w_service_point_modal_departure_authorization, style: DASTextStyles.smallRoman),
            Padding(
              padding: const .symmetric(vertical: 10.0, horizontal: sbbDefaultSpacing),
              child: Text.rich(TextUtil.parseHtmlText(departureAuthText, DASTextStyles.mediumRoman)),
            ),
          ],
        );
      },
    );
  }
}

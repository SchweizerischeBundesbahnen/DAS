import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/personal_note_dialog.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_notes_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/communication_network_icon.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/text_util.dart';
import 'package:flutter/material.dart';
import 'package:personal_notes/component.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DetailTabCommunication extends StatelessWidget {
  static const communicationTabKey = Key('communicationTab');
  static const radioChannelListKey = Key('communicationTabRadioChannelList');
  static const departureAuthorizationKey = Key('communicationTabDepartureAuthorization');

  const DetailTabCommunication({super.key = communicationTabKey});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _departureAuthorization(context),
            _communicationNetworkType(context),
            _contactList(context),
            _personalNote(context),
            _servicePointPortalButton(context),
          ],
        ),
      ),
    );
  }

  Widget _contactList(BuildContext context) {
    final content = StreamBuilder(
      stream: context.read<ServicePointModalViewModel>().radioContacts,
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
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          separatorBuilder: (_, _) => SBBDivider(),
          itemBuilder: (context, index) => _contactItem(contacts.elementAt(index)),
        );
      },
    );

    return Column(
      crossAxisAlignment: .start,
      children: [
        _listHeader(text: context.l10n.w_service_point_modal_communication_radio_channel),
        content,
      ],
    );
  }

  Widget _contactItem(Contact contact) {
    return Padding(
      padding: const .symmetric(horizontal: SBBSpacing.medium, vertical: 10.0),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 4.0,
        children: [
          if (contact.contactRole != null) Text(contact.contactRole!, style: sbbTextStyle.romanStyle.medium),
          Text(contact.contactIdentifier, style: sbbTextStyle.boldStyle.medium),
        ],
      ),
    );
  }

  Widget _communicationNetworkType(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.communicationNetworkType,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: .start,
          children: [
            _listHeader(text: context.l10n.w_service_point_modal_communication_network),
            Padding(
              padding: const .symmetric(horizontal: SBBSpacing.medium),
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
          crossAxisAlignment: .start,
          children: [
            _listHeader(text: context.l10n.w_service_point_modal_departure_authorization),
            Padding(
              padding: const .symmetric(horizontal: SBBSpacing.medium),
              child: Text.rich(
                TextUtil.parseHtmlTextWithMarkdownLinks(departureAuthText, sbbTextStyle.romanStyle.medium),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _servicePointPortalButton(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.servicePoint,
      builder: (context, snapshot) {
        final servicePoint = snapshot.data;
        if (servicePoint == null) return SizedBox.shrink();

        return Column(
          crossAxisAlignment: .start,
          children: [
            _listHeader(text: context.l10n.w_service_point_modal_links),
            SBBTertiaryButton(
              onPressed: () => DI.get<Launcher>().launchServicePointPortal(servicePoint),
              iconData: SBBIcons.link_external_small,
              labelText: context.l10n.w_service_point_modal_portal_label,
            ),
          ],
        );
      },
    );
  }

  Widget _personalNote(BuildContext context) {
    final viewModel = context.read<PersonalNotesViewModel>();
    return StreamBuilder(
      stream: viewModel.personalNote,
      builder: (context, snapshot) {
        final personalNote = snapshot.data;

        return Column(
          spacing: SBBSpacing.xSmall,
          crossAxisAlignment: .start,
          children: [
            _listHeader(text: context.l10n.w_service_point_modal_personal_note),
            if (personalNote != null)
              Container(
                padding: const .symmetric(
                  horizontal: SBBSpacing.medium,
                  vertical: SBBSpacing.xSmall,
                ),
                decoration: BoxDecoration(
                  borderRadius: SBBContentBoxStyle.radius,
                  border: BoxBorder.all(
                    color: ThemeUtil.getColor(context, SBBColors.silver, SBBColors.anthracite),
                  ),
                ),
                child: Text(personalNote.text),
              ),
            _personalNoteButton(context, personalNote),
          ],
        );
      },
    );
  }

  Widget _personalNoteButton(BuildContext context, PersonalNote? personalNote) {
    final icon = personalNote == null ? SBBIcons.plus_small : SBBIcons.pen_small;
    final label = personalNote == null
        ? context.l10n.w_service_point_modal_personal_note_create_button
        : context.l10n.w_service_point_modal_personal_note_edit_button;
    return SBBTertiaryButtonSmall(
      onPressed: () => showPersonalNoteDialog(context, personalNote),
      iconData: icon,
      labelText: label,
    );
  }

  Widget _listHeader({required String text}) => Padding(
    padding: const .only(top: SBBSpacing.small, bottom: SBBSpacing.xSmall),
    child: Text(text, style: sbbTextStyle.romanStyle.small),
  );
}

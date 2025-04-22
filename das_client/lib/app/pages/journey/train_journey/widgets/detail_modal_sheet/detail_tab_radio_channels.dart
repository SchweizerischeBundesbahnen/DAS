import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:das_client/model/journey/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DetailTabRadioChannels extends StatelessWidget {
  static const radioChannelsTabKey = Key('radioChannelsTabKey');

  const DetailTabRadioChannels({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalSheetViewModel>();
    return StreamBuilder(
      key: radioChannelsTabKey,
      stream: viewModel.radioContacts,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          // TODO: Add not found text
          return Center(child: Text('Not found'));
        }
        final contactList = snapshot.data!;
        return _contactList(contactList);
      },
    );
  }

  ListView _contactList(RadioContactList contactList) {
    return ListView.builder(
      itemCount: contactList.mainContacts.length,
      itemBuilder: (context, index) {
        final contact = contactList.mainContacts.elementAt(index);
        return SBBListItem(title: contact.contactRole ?? '', subtitle: contact.contactIdentifier, onPressed: null);
      },
    );
  }
}

import 'package:app/app/widgets/das_text_styles.dart';
import 'package:app/model/journey/contact_list.dart';
import 'package:flutter/material.dart';

class RadioContactChannels extends StatelessWidget {
  static const Key radioContactChannelsKey = Key('radioContactChannels');

  const RadioContactChannels({
    required this.contacts,
    super.key,
  });

  final RadioContactList? contacts;

  @override
  Widget build(BuildContext context) {
    return contacts?.mainContactsIdentifier != null
        ? Text(key: radioContactChannelsKey, contacts!.mainContactsIdentifier!, style: DASTextStyles.xLargeRoman)
        : SizedBox.shrink();
  }
}

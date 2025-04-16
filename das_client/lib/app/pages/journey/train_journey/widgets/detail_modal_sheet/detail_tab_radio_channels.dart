import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:flutter/material.dart';

// TODO: add implementation for tab views
class DetailTabRadioChannels extends StatelessWidget {
  static const radioChannelsTabKey = Key('radioChannelsTabKey');

  const DetailTabRadioChannels({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: radioChannelsTabKey,
      child: Text(
        DetailModalSheetTab.radioChannels.localized(context),
      ),
    );
  }
}

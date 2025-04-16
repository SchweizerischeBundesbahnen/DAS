import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:flutter/material.dart';

// TODO: add implementation for tab views
class DetailTabGraduatedSpeeds extends StatelessWidget {
  static const graduatedSpeedsTabKey = Key('graduatedSpeedsTabKey');

  const DetailTabGraduatedSpeeds({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: graduatedSpeedsTabKey,
      child: Text(
        DetailModalSheetTab.graduatedSpeeds.localized(context),
      ),
    );
  }
}

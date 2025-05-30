import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:flutter/material.dart';

// TODO: add implementation for tab views
class DetailTabLocalRegulations extends StatelessWidget {
  static const localRegulationsTabKey = Key('localRegulationsTabKey');

  const DetailTabLocalRegulations({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: localRegulationsTabKey,
      child: Text(
        ServicePointModalTab.localRegulations.localized(context),
      ),
    );
  }
}

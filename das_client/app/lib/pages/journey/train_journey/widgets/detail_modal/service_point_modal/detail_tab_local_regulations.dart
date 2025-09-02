import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/local_regulation_html_view.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class DetailTabLocalRegulations extends StatelessWidget {
  static const localRegulationsTabKey = Key('localRegulationsTabKey');

  const DetailTabLocalRegulations({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBGroup(
      color: SBBColors.white,
      child: StreamBuilder(
        stream: context.read<ServicePointModalViewModel>().localRegulationSections,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return _loading();

          final localRegulationSections = snapshot.requireData;
          return _content(localRegulationSections);
        },
      ),
    );
  }

  Widget _content(List<LocalRegulationSection> localRegulationSections) {
    return SingleChildScrollView(
      child: SBBAccordion(
        accordionCallback: (int index, bool isExpanded) {
          // TODO:
          print('$index, $isExpanded');
        },
        children: localRegulationSections.map<SBBAccordionItem>((section) {
          return SBBAccordionItem(
            title: section.title.localized,
            body: LocalRegulationHtmlView(html: section.content.localized),
            // TODO:
            isExpanded: true,
          );
        }).toList(),
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

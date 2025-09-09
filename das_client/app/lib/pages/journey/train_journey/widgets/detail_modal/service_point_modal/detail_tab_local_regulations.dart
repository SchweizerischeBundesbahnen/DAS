import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/local_regulation_html_view.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DetailTabLocalRegulations extends StatelessWidget {
  static const localRegulationsTabKey = Key('localRegulationsTabKey');

  const DetailTabLocalRegulations({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    if (isDarkTheme) {
      return SBBGroup(
        color: SBBColors.white,
        padding: EdgeInsets.all(sbbDefaultSpacing),
        child: _htmlView(context),
      );
    }

    return _htmlView(context);
  }

  StreamBuilder<String> _htmlView(BuildContext context) {
    return StreamBuilder(
      stream: context.read<ServicePointModalViewModel>().localRegulationHtml,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loading();

        final localRegulationHtml = snapshot.requireData;
        return LocalRegulationHtmlView(html: localRegulationHtml);
      },
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

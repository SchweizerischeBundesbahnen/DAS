import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/detail_tab_communication.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/detail_tab_graduated_speeds.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/detail_tab_local_regulations.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ServicePointModalBuilder extends DASModalSheetBuilder {
  static const segmentedButtonKey = Key('servicePointModalSegmentedButton');

  @override
  Widget body(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.selectedTab,
      builder: (context, snapshot) {
        final selectedTab = snapshot.data ?? ServicePointModalTab.values.first;
        return Column(
          children: [
            _segmentedIconButton(context, selectedTab),
            SizedBox(height: sbbDefaultSpacing),
            Expanded(child: _tabContent(context, selectedTab)),
          ],
        );
      },
    );
  }

  @override
  Widget header(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
          stream: viewModel.servicePoint,
          builder: (context, snapshot) {
            final name = snapshot.data?.name ?? context.l10n.c_unknown;
            return Text(name, style: DASTextStyles.largeRoman);
          },
        ),
        StreamBuilder(
          stream: viewModel.selectedTab,
          builder: (context, snapshot) {
            final selectedTab = snapshot.data ?? ServicePointModalTab.values.first;
            return Text(selectedTab.localized(context), style: DASTextStyles.extraSmallRoman);
          },
        ),
      ],
    );
  }

  Widget _segmentedIconButton(BuildContext context, ServicePointModalTab selectedTab) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return SBBSegmentedButton.icon(
      key: segmentedButtonKey,
      icons: {for (final tab in ServicePointModalTab.values) tab.icon: tab.localized(context)},
      selectedStateIndex: selectedTab.index,
      selectedIndexChanged: (index) => viewModel.open(context, tab: ServicePointModalTab.values[index]),
    );
  }

  Widget _tabContent(BuildContext context, ServicePointModalTab selectedTab) {
    switch (selectedTab) {
      case ServicePointModalTab.communication:
        return DetailTabCommunication();
      case ServicePointModalTab.graduatedSpeeds:
        return DetailTabGraduatedSpeeds();
      case ServicePointModalTab.localRegulations:
        return DetailTabLocalRegulations();
    }
  }
}

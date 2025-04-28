import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_graduated_speeds.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_local_regulations.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_tab_communication.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DetailModalSheet extends StatelessWidget {
  static const segmentedButtonKey = Key('detailModalSheetSegmentedButton');

  const DetailModalSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalSheetViewModel>();
    return StreamBuilder(
      stream: viewModel.selectedTab,
      builder: (context, snapshot) {
        final selectedTab = snapshot.data ?? DetailModalSheetTab.values.first;
        return DasModalSheet(
          controller: viewModel.controller,
          leftMargin: sbbDefaultSpacing * 0.5,
          header: _header(viewModel, subtitle: selectedTab.localized(context)),
          child: _body(context, selectedTab),
        );
      },
    );
  }

  Widget _body(BuildContext context, DetailModalSheetTab selectedTab) {
    return Column(
      children: [
        _segmentedIconButton(context, selectedTab),
        SizedBox(height: sbbDefaultSpacing),
        Expanded(child: _tabContent(context, selectedTab)),
      ],
    );
  }

  Widget _header(DetailModalSheetViewModel viewModel, {required String subtitle}) {
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
        Text(subtitle, style: DASTextStyles.extraSmallRoman),
      ],
    );
  }

  Widget _segmentedIconButton(BuildContext context, DetailModalSheetTab selectedTab) {
    final viewModel = context.read<DetailModalSheetViewModel>();
    return SBBSegmentedButton.icon(
      key: segmentedButtonKey,
      icons: {for (final tab in DetailModalSheetTab.values) tab.icon: tab.localized(context)},
      selectedStateIndex: selectedTab.index,
      selectedIndexChanged: (index) => viewModel.open(tab: DetailModalSheetTab.values[index]),
    );
  }

  Widget _tabContent(BuildContext context, DetailModalSheetTab selectedTab) {
    switch (selectedTab) {
      case DetailModalSheetTab.communication:
        return DetailTabCommunication();
      case DetailModalSheetTab.graduatedSpeeds:
        return DetailTabGraduatedSpeeds();
      case DetailModalSheetTab.localRegulations:
        return DetailTabLocalRegulations();
    }
  }
}

import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_tab.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal_sheet/detail_modal_sheet_view_model.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// TODO: Schliessen? -> Das Modal bleibt dann mindestens 10 Sekunden geöffnet, nachdem der Bildschirm nicht mehr berührt wurde.
/// TODO: Im reduzierten Fahrbild-Ansicht logik wie folgt: obald das Modal geöffnet wird, positioniert sich das Fahrbild neu an die Stelle, an der gerade gefahren wird, falls die automatische Fortschaltung aktiviert ist.
class DetailModalSheet extends StatelessWidget {
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
          header: _header(
            // TODO: Add current BP
            title: 'Bern',
            subtitle: selectedTab.localized(context),
          ),
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

  Widget _header({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DASTextStyles.largeRoman),
        Text(subtitle, style: DASTextStyles.extraSmallRoman),
      ],
    );
  }

  Widget _segmentedIconButton(BuildContext context, DetailModalSheetTab selectedTab) {
    final viewModel = context.read<DetailModalSheetViewModel>();
    return SBBSegmentedButton.icon(
      icons: {for (final tab in DetailModalSheetTab.values) tab.icon: tab.localized(context)},
      selectedStateIndex: selectedTab.index,
      selectedIndexChanged: (index) => viewModel.open(tab: DetailModalSheetTab.values[index]),
    );
  }

  // TODO: add implementation for tab views
  Widget _tabContent(BuildContext context, DetailModalSheetTab selectedTab) {
    switch (selectedTab) {
      case DetailModalSheetTab.radioChannels:
        return Center(child: Text(selectedTab.localized(context)));
      case DetailModalSheetTab.graduatedSpeeds:
        return Center(child: Text(selectedTab.localized(context)));
      case DetailModalSheetTab.localRegulations:
        return Center(child: Text(selectedTab.localized(context)));
    }
  }
}

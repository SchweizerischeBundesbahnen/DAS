import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// TODO: maybe use view model?
/// TODO: Hide kilometre from train journey table
/// TODO: Allow open for certain tab
/// TODO: Change buttons to IconButtons in Header
class DetailModalSheet extends StatefulWidget {
  const DetailModalSheet({
    required this.controller,
    super.key,
  });

  final DASModalSheetController controller;

  @override
  State<DetailModalSheet> createState() => _DetailModalSheetState();
}

enum _DetailTabs {
  radioChannels(icon: SBBIcons.telephone_gsm_small),
  graduatedSpeeds(icon: SBBIcons.question_mark_small),
  localRegulations(icon: SBBIcons.location_pin_surrounding_area_small);

  const _DetailTabs({required this.icon});

  String localized(BuildContext context) {
    switch (this) {
      case radioChannels:
        return context.l10n.w_detail_modal_sheet_radio_channel_label;
      case graduatedSpeeds:
        return context.l10n.w_detail_modal_sheet_graduated_speed_label;
      case localRegulations:
        return context.l10n.w_detail_modal_sheet_local_regulations_label;
    }
  }

  final IconData icon;
}

class _DetailModalSheetState extends State<DetailModalSheet> {
  var _selectedTab = _DetailTabs.radioChannels;

  @override
  Widget build(BuildContext context) {
    return DasModalSheet(
      controller: widget.controller,
      leftMargin: sbbDefaultSpacing * 0.5,
      header: _header(),
      child: Column(
        children: [
          _segmentedIconButton(),
          SizedBox(height: sbbDefaultSpacing),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TODO: Add current BP
        Text('Baumen', style: DASTextStyles.largeRoman),
        Text(_selectedTab.localized(context), style: DASTextStyles.extraSmallRoman),
      ],
    );
  }

  Widget _segmentedIconButton() {
    return SBBSegmentedButton.icon(
      icons: {for (final tab in _DetailTabs.values) tab.icon: tab.localized(context)},
      selectedStateIndex: _selectedTab.index,
      selectedIndexChanged: (index) {
        setState(() {
          _selectedTab = _DetailTabs.values[index];
        });

        if (_selectedTab == _DetailTabs.localRegulations) {
          widget.controller.fullOpen();
        } else {
          widget.controller.open();
        }
      },
    );
  }

  // TODO: add implementation for tab views
  Widget _body() {
    switch (_selectedTab) {
      case _DetailTabs.radioChannels:
        return Center(child: Text(_selectedTab.localized(context)));
      case _DetailTabs.graduatedSpeeds:
        return Center(child: Text(_selectedTab.localized(context)));
      case _DetailTabs.localRegulations:
        return Center(child: Text(_selectedTab.localized(context)));
    }
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/detail_tab_communication.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/detail_tab_graduated_speeds.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/detail_tab_local_regulations.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_tab.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ServicePointModalBuilder extends DASModalSheetBuilder {
  static const segmentedButtonKey = Key('servicePointModalSegmentedButton');

  @override
  Widget body(BuildContext context) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      initialData: viewModel.selectedTabValue,
      stream: viewModel.selectedTab,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final selectedTab = snapshot.data!;
        return Column(
          children: [
            _segmentedIconButton(context, selectedTab),
            SizedBox(height: SBBSpacing.medium),
            Expanded(child: _tabContent(context, selectedTab)),
          ],
        );
      },
    );
  }

  @override
  Widget header(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        _headerTitle(context),
        _headerSubtitle(context),
      ],
    );
  }

  Widget _headerTitle(BuildContext context) {
    return StreamBuilder(
      stream: context.read<ServicePointModalViewModel>().servicePoint,
      builder: (context, snapshot) {
        final servicePointName = snapshot.data?.name;
        if (servicePointName == null) {
          return Skeletonizer(
            enabled: !snapshot.hasData,
            child: Text(context.l10n.c_unknown, style: sbbTextStyle.romanStyle.large),
          );
        }

        return AnimatedSwitcher(
          duration: DASAnimation.shortDuration,
          transitionBuilder: (child, animation) {
            final centerLeftTween = AlignmentTween(begin: .centerLeft, end: .centerLeft);
            return AlignTransition(
              alignment: centerLeftTween.animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: Text(
            servicePointName,
            key: ValueKey(servicePointName),
            style: sbbTextStyle.romanStyle.large,
          ),
        );
      },
    );
  }

  Widget _headerSubtitle(BuildContext context) {
    return StreamBuilder(
      stream: context.read<ServicePointModalViewModel>().selectedTab,
      builder: (context, snapshot) {
        final tabSubtitle = snapshot.data?.localized(context) ?? BoneMock.subtitle;
        return Skeletonizer(
          enabled: !snapshot.hasData,
          child: Text(tabSubtitle, style: sbbTextStyle.romanStyle.xSmall),
        );
      },
    );
  }

  Widget _segmentedIconButton(BuildContext context, ServicePointModalTab selectedTab) {
    final viewModel = context.read<ServicePointModalViewModel>();
    return StreamBuilder(
      stream: viewModel.tabs,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Skeletonizer(
            enabled: true,
            child: SBBSegmentedButton(values: [BoneMock.title], selectedStateIndex: 0, selectedIndexChanged: (_) {}),
          );
        }

        final tabs = snapshot.requireData;
        return SBBSegmentedButton.icon(
          key: segmentedButtonKey,
          icons: {for (final tab in tabs) tab.icon: tab.localized(context)},
          selectedStateIndex: tabs.indexOf(selectedTab),
          selectedIndexChanged: (index) => viewModel.open(context, tab: tabs[index]),
        );
      },
    );
  }

  Widget _tabContent(BuildContext context, ServicePointModalTab selectedTab) {
    return switch (selectedTab) {
      .communication => DetailTabCommunication(),
      .graduatedSpeeds => DetailTabGraduatedSpeeds(),
      .localRegulations => DetailTabLocalRegulations(),
    };
  }
}

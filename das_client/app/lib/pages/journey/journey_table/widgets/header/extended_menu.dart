import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_table/widgets/anchored_full_page_overlay.dart';
import 'package:app/pages/journey/journey_table/widgets/reduced_overview/reduced_overview_modal_sheet.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ExtendedMenu extends StatelessWidget {
  static const Key menuButtonKey = Key('extendedMenuButton');
  static const Key menuButtonCloseKey = Key('closeExtendedMenuButton');
  static const Key maneuverSwitchKey = Key('maneuverSwitch');
  static const Key openWaraAppMenuItemKey = Key('openWaraAppMenuItem');

  const ExtendedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneyTableViewModel>();
    return AnchoredFullPageOverlay(
      triggerBuilder: (_, showOverlay) => SBBIconButtonLarge(
        key: menuButtonKey,
        icon: SBBIcons.context_menu_small,
        onPressed: () => showOverlay(),
      ),
      contentBuilder: (_, hideOverlay) {
        return Provider(
          create: (_) => viewModel,
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: .start,
              children: [
                _menuHeader(context, hideOverlay),
                SizedBox(height: sbbDefaultSpacing),
                SBBGroup(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      _breakSlipItem(context),
                      _transportDocumentItem(context),
                      _journeyOverviewItem(context, hideOverlay),
                      _maneuverItem(context, hideOverlay),
                      _waraItem(context, hideOverlay),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuHeader(BuildContext context, VoidCallback hideOverlay) {
    return Row(
      crossAxisAlignment: .center,
      children: [
        Expanded(
          child: Text(
            context.l10n.w_extended_menu_title,
            style: DASTextStyles.largeLight,
          ),
        ),
        SBBIconButtonSmall(
          key: menuButtonCloseKey,
          onPressed: () => hideOverlay(),
          icon: SBBIcons.cross_small,
        ),
      ],
    );
  }

  Widget _breakSlipItem(BuildContext context) {
    return SBBListItem(
      title: context.l10n.w_extended_menu_breaking_slip_action,
      onPressed: () {
        // Placeholder
      },
    );
  }

  Widget _transportDocumentItem(BuildContext context) {
    return SBBListItem(
      title: context.l10n.w_extended_menu_transport_document_action,
      onPressed: () {
        // Placeholder
      },
    );
  }

  Widget _journeyOverviewItem(BuildContext context, VoidCallback hideOverlay) {
    return SBBListItem(
      title: context.l10n.w_extended_menu_journey_overview_action,
      onPressed: () {
        hideOverlay();
        if (context.mounted) {
          showReducedOverviewModalSheet(context);
        }
      },
    );
  }

  Widget _waraItem(BuildContext context, VoidCallback hideOverlay) {
    final warnAppViewModel = context.read<WarnAppViewModel>();
    return FutureBuilder(
      future: warnAppViewModel.isWaraAppInstalled,
      builder: (context, snapshot) {
        final isWaraAppInstalled = snapshot.data ?? false;
        if (!isWaraAppInstalled) return SizedBox.shrink();

        return SBBListItem(
          key: openWaraAppMenuItemKey,
          title: context.l10n.w_extended_menu_journey_wara_action,
          trailingIcon: SBBIcons.link_external_medium,
          isLastElement: true,
          onPressed: () async {
            await warnAppViewModel.openWaraApp();
            hideOverlay();
          },
        );
      },
    );
  }

  Widget _maneuverItem(BuildContext context, VoidCallback hideOverlay) {
    final viewModel = context.read<WarnAppViewModel>();

    return FutureBuilder(
      future: viewModel.isWarnappFeatureEnabled,
      builder: (context, asyncSnapshot) {
        if (!asyncSnapshot.hasData || asyncSnapshot.data == false) return SizedBox.shrink();

        return SBBListItem.custom(
          title: context.l10n.w_extended_menu_maneuver_mode,
          onPressed: () {
            hideOverlay();
            viewModel.toggleManeuverMode();
          },
          trailingWidget: Padding(
            padding: const .fromLTRB(0, 0, sbbDefaultSpacing * 0.5, 0),
            child: StreamBuilder(
              stream: viewModel.isManeuverModeEnabled,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox.shrink();

                final isManeuverModeEnabled = snapshot.requireData;
                return SBBSwitch(
                  key: maneuverSwitchKey,
                  value: isManeuverModeEnabled,
                  onChanged: (value) {
                    hideOverlay();
                    viewModel.setManeuverMode(value);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}

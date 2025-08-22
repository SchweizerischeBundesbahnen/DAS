import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/train_journey/widgets/anchored_full_page_overlay.dart';
import 'package:app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_modal_sheet.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ExtendedMenu extends StatelessWidget {
  static const Key menuButtonKey = Key('extendedMenuButton');
  static const Key menuButtonCloseKey = Key('closeExtendedMenuButton');
  static const Key maneuverSwitchKey = Key('maneuverSwitch');

  const ExtendedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return AnchoredFullPageOverlay(
      triggerBuilder: (context, showOverlay) => SBBIconButtonLarge(
        key: menuButtonKey,
        icon: SBBIcons.context_menu_small,
        onPressed: () => showOverlay(),
      ),
      contentBuilder: (context, hideOverlay) {
        return Provider(
          create: (_) => viewModel,
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _menuHeader(context, hideOverlay),
                SizedBox(height: sbbDefaultSpacing),
                SBBGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _breakSlipItem(context),
                      _transportDocumentItem(context),
                      _journeyOverviewItem(context, hideOverlay),
                      _maneuverItem(context, hideOverlay),
                      _waraItem(context),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
        hideOverlay;
        if (context.mounted) {
          DASTableRowBuilder.clearRowKeys();
          showReducedOverviewModalSheet(
            context,
          ).then((_) => Future.delayed(const Duration(milliseconds: 250), () => hideOverlay()));
        }
      },
    );
  }

  Widget _waraItem(BuildContext context) {
    return SBBListItem(
      title: context.l10n.w_extended_menu_journey_wara_action,
      trailingIcon: SBBIcons.link_external_medium,
      isLastElement: true,
      onPressed: () {
        // Placeholder
      },
    );
  }

  Widget _maneuverItem(BuildContext context, VoidCallback hideOverlay) {
    final viewModel = context.read<TrainJourneyViewModel>();

    return SBBListItem.custom(
      title: context.l10n.w_extended_menu_maneuver_mode,
      onPressed: () {
        hideOverlay();
        final maneuverModeToggled = !viewModel.settingsValue.isManeuverModeEnabled;
        viewModel.setManeuverMode(maneuverModeToggled);
      },
      trailingWidget: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, sbbDefaultSpacing * 0.5, 0),
        child: StreamBuilder<TrainJourneySettings>(
          stream: viewModel.settings,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();

            return SBBSwitch(
              key: maneuverSwitchKey,
              value: snapshot.data?.isManeuverModeEnabled ?? false,
              onChanged: (value) {
                hideOverlay();
                viewModel.setManeuverMode(value);
              },
            );
          },
        ),
      ),
    );
  }
}

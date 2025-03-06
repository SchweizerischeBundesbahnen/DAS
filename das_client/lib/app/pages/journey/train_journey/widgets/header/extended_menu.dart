import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ExtendedMenu extends StatefulWidget {
  const ExtendedMenu({super.key});

  @override
  State<ExtendedMenu> createState() => _ExtendedMenuState();
}

class _ExtendedMenuState extends State<ExtendedMenu> {
  static const extendedMenuContentWidth = 360.0;

  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    return SBBIconButtonLarge(
      icon: SBBIcons.context_menu_small,
      onPressed: () {
        _showOverlay(context);
      },
    );
  }

  void _removeOverlay() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  void _showOverlay(BuildContext context) {
    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final positionOffset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: [
          // Fullscreen background
          GestureDetector(
            onTap: () => _removeOverlay(),
            child: Container(
              color: SBBColors.iron.withAlpha((255.0 * 0.6).round()),
            ),
          ),
          // Positioned overlay
          Positioned(
            // Position center of button
            left: positionOffset.dx - extendedMenuContentWidth / 2 + size.width / 2,
            // Position below the button
            top: positionOffset.dy + size.height + sbbDefaultSpacing / 2,
            child: _menuContent(
              context,
            ),
          ),
        ],
      ),
    );

    // Insert the overlay entry into the Overlay
    overlayState.insert(overlayEntry!);
  }

  Widget _menuContent(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: SBBColors.milk,
          borderRadius: BorderRadius.circular(sbbDefaultSpacing),
        ),
        width: extendedMenuContentWidth,
        child: Padding(
          padding: const EdgeInsets.all(sbbDefaultSpacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _menuHeader(context),
              SizedBox(height: sbbDefaultSpacing),
              SBBGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _breakSlipItem(context),
                    _divider(),
                    _transportDocumentItem(context),
                    _divider(),
                    _journeyOverviewItem(context),
                    _divider(),
                    _maneuverItem(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            context.l10n.w_extended_menu_title,
            style: SBBTextStyles.largeLight,
          ),
        ),
        SBBIconButtonSmall(
          onPressed: () {
            _removeOverlay();
          },
          icon: SBBIcons.cross_small,
        ),
      ],
    );
  }

  Widget _breakSlipItem(BuildContext context) {
    return InkWell(
      onTap: () {
        // Placeholder
      },
      child: _itemPadding(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            context.l10n.w_extended_menu_breaking_slip_action,
            style: SBBTextStyles.mediumLight,
          ),
        ),
      ),
    );
  }

  Widget _transportDocumentItem(BuildContext context) {
    return InkWell(
      onTap: () {
        // Placeholder
      },
      child: _itemPadding(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            context.l10n.w_extended_menu_transport_document_action,
            style: SBBTextStyles.mediumLight,
          ),
        ),
      ),
    );
  }

  Widget _journeyOverviewItem(BuildContext context) {
    return InkWell(
      onTap: () {
        // Placeholder
      },
      child: _itemPadding(
        child: SizedBox(
          width: double.infinity,
          child: Text(
            context.l10n.w_extended_menu_journey_overview_action,
            style: SBBTextStyles.mediumLight,
          ),
        ),
      ),
    );
  }

  Widget _maneuverItem(BuildContext context) {
    final trainJourneyCubit = DI.get<TrainJourneyCubit>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              context.l10n.w_extended_menu_maneuver_mode,
              style: SBBTextStyles.mediumLight,
            ),
          ),
          StreamBuilder<TrainJourneySettings>(
            stream: trainJourneyCubit.settingsStream,
            builder: (context, snapshot) {
              return SBBSwitch(
                value: snapshot.data?.maneuverMode ?? false,
                onChanged: (bool value) {
                  trainJourneyCubit.setManeuverMode(value);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1.0, color: SBBColors.cloud);

  Widget _itemPadding({required Widget child}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing, vertical: 10),
        child: child,
      );
}

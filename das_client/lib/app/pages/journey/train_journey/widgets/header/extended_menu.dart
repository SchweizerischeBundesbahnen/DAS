import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/reduced_overview/reduced_overview_modal_sheet.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/di.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ExtendedMenu extends StatefulWidget {
  static const Key menuButtonKey = Key('extendedMenuButton');
  static const Key menuButtonCloseKey = Key('closeExtendedMenuButton');
  static const Key maneuverSwitchKey = Key('maneuverSwitch');

  const ExtendedMenu({super.key});

  @override
  State<ExtendedMenu> createState() => _ExtendedMenuState();
}

class _ExtendedMenuState extends State<ExtendedMenu> with SingleTickerProviderStateMixin {
  static const extendedMenuContentWidth = 360.0;
  static const extendedMenuContentHeightOffset = 10;

  OverlayEntry? overlayEntry;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SBBIconButtonLarge(
      key: ExtendedMenu.menuButtonKey,
      icon: SBBIcons.context_menu_small,
      onPressed: () => _showOverlay(context),
    );
  }

  Future<void> _removeOverlay() async {
    await _controller.reverse();
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
      builder: (context) => Stack(
        children: [
          // Fullscreen background
          GestureDetector(
            onTap: () => _removeOverlay(),
            child: Container(
              color: SBBColors.iron.withAlpha((255.0 * 0.6).round()),
            ),
          ),
          // Positioned extended menu
          Positioned(
            left: positionOffset.dx - extendedMenuContentWidth / 2 + size.width / 2,
            top: positionOffset.dy + size.height + extendedMenuContentHeightOffset,
            child: _menu(context),
          ),
        ],
      ),
    );

    // Insert the overlay entry into the Overlay
    overlayState.insert(overlayEntry!);
    _controller.forward(); // Start the animation
  }

  Widget _menu(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            SvgPicture.asset(
              AppAssets.shapeMenuArrow,
              colorFilter: ColorFilter.mode(
                ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
                BlendMode.srcIn,
              ),
            ),
            _menuContent(context),
          ],
        ),
      ),
    );
  }

  Widget _menuContent(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
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
                    _transportDocumentItem(context),
                    _journeyOverviewItem(context),
                    _maneuverItem(context),
                    _waraItem(context),
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
            style: DASTextStyles.largeLight,
          ),
        ),
        SBBIconButtonSmall(
          key: ExtendedMenu.menuButtonCloseKey,
          onPressed: () => _removeOverlay(),
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

  Widget _journeyOverviewItem(BuildContext context) {
    return SBBListItem(
      title: context.l10n.w_extended_menu_journey_overview_action,
      onPressed: () async {
        await _removeOverlay();
        if (context.mounted) {
          showReducedOverviewModalSheet(context);
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

  Widget _maneuverItem(BuildContext context) {
    final trainJourneyCubit = DI.get<TrainJourneyCubit>();

    return SBBListItem.custom(
      title: context.l10n.w_extended_menu_maneuver_mode,
      onPressed: () => trainJourneyCubit.setManeuverMode(!trainJourneyCubit.settings.maneuverMode),
      trailingWidget: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, sbbDefaultSpacing * 0.5, 0),
        child: StreamBuilder<TrainJourneySettings>(
          stream: trainJourneyCubit.settingsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();

            return SBBSwitch(
              key: ExtendedMenu.maneuverSwitchKey,
              value: snapshot.data?.maneuverMode ?? false,
              onChanged: (value) => trainJourneyCubit.setManeuverMode(value),
            );
          },
        ),
      ),
    );
  }
}

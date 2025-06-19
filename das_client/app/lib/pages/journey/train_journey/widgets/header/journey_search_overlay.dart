import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_load_button.dart';
import 'package:app/pages/journey/selection/widgets/journey_railway_undertaking_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _anchorsOffset = Offset(0, sbbDefaultSpacing / 2);

class JourneySearchOverlay extends StatefulWidget {
  static const Key journeySearchKey = Key('journeySearchButton');
  static const Key journeySearchCloseKey = Key('closeJourneySearchButton');

  const JourneySearchOverlay({super.key});

  @override
  State<JourneySearchOverlay> createState() => _JourneySearchOverlayState();
}

class _JourneySearchOverlayState extends State<JourneySearchOverlay> with SingleTickerProviderStateMixin {
  static const extendedMenuContentWidth = 360.0;

  final _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneySelectionViewModel>();
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (_) => Provider(
        create: (_) => viewModel,
        child: Builder(
          builder: (context) => Stack(
            children: [
              // Fullscreen background
              GestureDetector(
                onTap: () => _removeOverlay(),
                child: Container(
                  color: SBBColors.iron.withAlpha((255.0 * 0.6).round()),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                offset: _anchorsOffset,
                targetAnchor: Alignment.bottomCenter,
                followerAnchor: Alignment.topCenter,
                child: _menu(context),
              ),

              // Positioned extended menu
            ],
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: SBBIconButtonLarge(
          key: JourneySearchOverlay.journeySearchKey,
          icon: SBBIcons.magnifying_glass_small,
          onPressed: () {
            final viewModel = DI.get<JourneySelectionViewModel>();
            viewModel.dismissSelection();
            _showOverlay();
          },
        ),
      ),
    );
  }

  Future<void> _showOverlay() async {
    _overlayController.show();
    _animationController.forward();
  }

  Future<void> _removeOverlay() async {
    await _animationController.reverse();
    _overlayController.hide();
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
                    JourneyTrainNumberInput(isModalVersion: true),
                    JourneyDateInput(isModalVersion: true),
                    JourneyRailwayUndertakingInput(isModalVersion: true),
                  ],
                ),
              ),
              JourneyLoadButton(),
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
            context.l10n.w_journey_search_overlay_title,
            style: DASTextStyles.largeLight,
          ),
        ),
        SBBIconButtonSmall(
          key: JourneySearchOverlay.journeySearchCloseKey,
          onPressed: () => _removeOverlay(),
          icon: SBBIcons.cross_small,
        ),
      ],
    );
  }
}

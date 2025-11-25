import 'package:app/theme/theme_util.dart';
import 'package:app/util/animation.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _fullPageBackgroundColor = SBBColors.iron.withAlpha((255.0 * 0.6).round());

/// Creates a widget that has two states:
/// 1. "collapsed": a triggering widget, that can be interacted with to show the overlay and transition to the second state
/// 2. "overlay": a full screen overlay with two "layers":
///     1. a grayed out background across the whole screen
///     2. a widget with the given [contentWidth] on top positioned relative to the triggering widget
///
/// Implemented using an [OverlayPortal] and a [CompositedTransformTarget]. Control the relative positioning of the
/// triggering widget and the widget in the overlay with [targetAnchor], [followerAnchor] and [offset].
class AnchoredFullPageOverlay extends StatefulWidget {
  const AnchoredFullPageOverlay({
    required this.triggerBuilder,
    required this.contentBuilder,
    super.key,
    this.contentWidth = 360.0,
    this.openAnimationDuration = DASAnimation.mediumDuration,
    this.closeAnimationDuration = DASAnimation.shortDuration,
    this.targetAnchor = Alignment.bottomCenter,
    this.followerAnchor = Alignment.topCenter,
    this.offset = const Offset(0, sbbDefaultSpacing / 2),
    this.isClosableOnBackgroundTap = true,
  });

  /// The builder that will display the triggering widget. Usually some form of a button.
  final Widget Function(BuildContext context, VoidCallback showOverlay) triggerBuilder;

  /// The content to display in the overlay
  final Widget Function(BuildContext context, VoidCallback closeOverlay) contentBuilder;

  /// The width of the overlay content.
  ///
  /// Defaults to 360.
  final double contentWidth;

  /// The duration of the opening animation.
  final Duration openAnimationDuration;

  /// The duration of the collapsing animation.
  final Duration closeAnimationDuration;

  /// Alignment of the trigger (where the overlay will point to)
  final Alignment targetAnchor;

  /// Alignment of the overlay (where it will be positioned relative to the trigger)
  final Alignment followerAnchor;

  /// Offset between the trigger and the overlay
  final Offset offset;

  final bool isClosableOnBackgroundTap;

  static double get defaultContentWidth => 360.0;

  @override
  State<AnchoredFullPageOverlay> createState() => _AnchoredFullPageOverlayState();
}

class _AnchoredFullPageOverlayState extends State<AnchoredFullPageOverlay> with SingleTickerProviderStateMixin {
  final _overlayController = OverlayPortalController();
  final _layerLink = LayerLink();

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.openAnimationDuration,
      reverseDuration: widget.closeAnimationDuration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController.toEmphasizedEasingAnimation());
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(_animationController.toEmphasizedEasingAnimation());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (_) => Stack(
        children: [
          // Fullscreen background
          GestureDetector(
            onTap: widget.isClosableOnBackgroundTap ? () => _removeOverlay() : null,
            child: Container(
              color: _fullPageBackgroundColor,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            offset: widget.offset,
            targetAnchor: widget.targetAnchor,
            followerAnchor: widget.followerAnchor,
            child: _animatedContent(context),
          ),
        ],
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: widget.triggerBuilder(context, _showOverlay),
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

  Widget _animatedContent(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.targetAnchor.x < 0.0 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: .symmetric(horizontal: widget.contentWidth / 4),
              child: SvgPicture.asset(
                AppAssets.shapeMenuArrow,
                colorFilter: ColorFilter.mode(
                  ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
                  borderRadius: BorderRadius.circular(sbbDefaultSpacing),
                ),
                width: widget.contentWidth,
                child: Padding(
                  padding: const .all(sbbDefaultSpacing),
                  child: widget.contentBuilder(context, _removeOverlay),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

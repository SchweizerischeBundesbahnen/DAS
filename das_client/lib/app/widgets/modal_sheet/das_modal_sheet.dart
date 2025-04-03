import 'dart:math';

import 'package:das_client/app/widgets/extended_header_container.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Used to open and close the [DasModalSheet] and handle animation.
class DASModalSheetController {
  DASModalSheetController({
    this.animationDuration = const Duration(milliseconds: 150),
    this.maxExtensionWidth = 300.0,
  });

  /// defines animation duration for opening and full-width extension of modal sheet.
  final Duration animationDuration;

  /// sets the maximum extension width for the non-overlapping modal sheet.
  final double maxExtensionWidth;

  bool _isOpen = false;

  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late AnimationController _fullWidthController;
  late Animation<double> _fullWidthAnimation;

  void _initialize({required TickerProvider vsync, VoidCallback? onUpdate}) {
    _controller = AnimationController(vsync: vsync, duration: animationDuration);
    _widthAnimation = Tween<double>(begin: 0.0, end: maxExtensionWidth).animate(_controller)
      ..addListener(() => onUpdate?.call());

    _fullWidthController = AnimationController(vsync: vsync, duration: animationDuration);
    _fullWidthAnimation = Tween<double>(begin: 0, end: 1).animate(_fullWidthController)
      ..addListener(() => onUpdate?.call());
  }

  void open() async {
    await _controller.forward();
    _isOpen = true;
  }

  void close() async {
    _controller.reverse();
    _fullWidthController.reverse();
    _isOpen = false;
  }

  void fullOpen() {
    _isOpen = true;
    _fullWidthController.forward();
  }

  double get width => _widthAnimation.value;

  double get fullWidth => _fullWidthAnimation.value;

  bool get isOpen => _isOpen;
}

/// Modal sheet that that can extend to a certain width and occupy this space but also overlap to the full screen width.
///
/// Modal sheet is controlled by [DASModalSheetController]
class DasModalSheet extends StatefulWidget {
  const DasModalSheet({
    required this.child,
    required this.controller,
    super.key,
    this.header,
    this.onClose,
    this.onOpen,
  });

  final VoidCallback? onClose;
  final VoidCallback? onOpen;
  final Widget child;
  final Widget? header;
  final DASModalSheetController controller;

  @override
  State<DasModalSheet> createState() => _DASModalSheetState();
}

class _DASModalSheetState extends State<DasModalSheet> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.controller._initialize(vsync: this, onUpdate: () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final modalWidth = _calculateModalWidth(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // invisible widget used to extend stack width
        Container(width: min(widget.controller.maxExtensionWidth, modalWidth)),
        // visible modal sheet that can overlap stack and extend to full width
        Positioned(right: 0, top: 0, bottom: 0, child: _modalSheet(modalWidth)),
      ],
    );
  }

  Widget _modalSheet(double width) {
    return ExtendedAppBarWrapper(
      child: Container(
        width: width,
        padding: EdgeInsets.all(sbbDefaultSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(sbbDefaultSpacing * 2)),
          color: SBBColors.white, // TODO: Dark Theme
        ),
        child: widget.controller.isOpen ? _body() : SizedBox(height: double.infinity),
      ),
    );
  }

  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _header(),
        SizedBox(height: sbbDefaultSpacing * 0.5),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: widget.header != null ? widget.header! : SizedBox(),
        ),
        _CloseButton(onClose: () => widget.controller.close()),
      ],
    );
  }

  double _calculateModalWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final animatedWidthOfController = widget.controller.width + (widget.controller.fullWidth * screenWidth);
    return min(animatedWidthOfController, screenWidth);
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return SBBIconButtonLarge(
      onPressed: onClose,
      icon: SBBIcons.cross_small,
    );
  }
}

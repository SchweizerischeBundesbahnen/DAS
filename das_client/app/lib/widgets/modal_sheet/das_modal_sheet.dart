import 'dart:async';
import 'dart:math';

import 'package:app/widgets/extended_header_container.dart';
import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

enum _ControllerState { closed, expanded, maximized }

/// Used to build header and body widgets for [DasModalSheet]
class DASModalSheetBuilder {
  Widget? header(BuildContext context) => null;

  Widget body(BuildContext context) => SizedBox.shrink();
}

/// Used to open and close the [DasModalSheet] and handle animation.
class DASModalSheetController {
  static int automaticCloseAfterSeconds = 10;

  DASModalSheetController({
    this.animationDuration = const Duration(milliseconds: 150),
    this.maxExpandedWidth = 300.0,
    this.onClose,
    this.onOpen,
  }) : _state = _ControllerState.closed;

  /// defines animation duration for opening and full-width extension of modal sheet.
  final Duration animationDuration;

  /// sets the maximum expanded width for the non-overlapping modal sheet.
  final double maxExpandedWidth;

  final VoidCallback? onClose;
  final VoidCallback? onOpen;

  _ControllerState _state;
  bool _initialized = false;

  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late AnimationController _fullWidthController;
  late Animation<double> _fullWidthAnimation;

  Timer? _idleTimer;

  /// will be called by [DasModalSheet] to get [TickerProvider]
  void _initialize({required TickerProvider vsync, VoidCallback? onUpdate}) {
    _controller = AnimationController(vsync: vsync, duration: animationDuration);
    // TODO: Rename and add https://stackoverflow.com/questions/55364049/how-do-you-add-a-curves-class-animation-to-animationcontroller-in-flutter
    _widthAnimation = Tween<double>(begin: 0.0, end: maxExpandedWidth).animate(_controller)
      ..addListener(() => onUpdate?.call());

    _fullWidthController = AnimationController(vsync: vsync, duration: animationDuration);
    _fullWidthAnimation = Tween<double>(begin: 0, end: 1).animate(_fullWidthController)
      ..addListener(() => onUpdate?.call());

    _initialized = true;
  }

  /// expands or reduces width of modal sheet to [maxExpandedWidth] if not already in expanded state
  Future<void> expand() async {
    if (!_initialized) return;

    if (_state == _ControllerState.closed) {
      onOpen?.call();
      await _controller.forward();
      _state = _ControllerState.expanded;
    } else if (_state == _ControllerState.maximized) {
      _fullWidthController.reverse();
      _state = _ControllerState.expanded;
    }
    resetAutomaticClose();
  }

  /// maximizes modal sheet to fill the full screen width
  Future<void> maximize() async {
    if (!_initialized) return;

    if (_state != _ControllerState.maximized) {
      onOpen?.call();
      await _fullWidthController.forward();
      _state = _ControllerState.maximized;
    }
    resetAutomaticClose();
  }

  /// closes the modal sheet if not already closed
  void close() {
    if (!_initialized) return;

    if (_state != _ControllerState.closed) {
      onClose?.call();
      _controller.reverse();
      _fullWidthController.reverse();
      _state = _ControllerState.closed;
    }
    resetAutomaticClose();
  }

  /// resets timer for automatic close when activated and modal sheet is open
  void resetAutomaticClose() {
    _idleTimer?.cancel();
    if (isOpen) {
      _idleTimer = Timer(Duration(seconds: automaticCloseAfterSeconds), () {
        if (isOpen) {
          Fimber.d('Screen idle time of $automaticCloseAfterSeconds seconds reached. Closing DAS modal sheet.');
          close();
        }
      });
    }
  }

  void dispose() {
    _idleTimer?.cancel();
    _controller.dispose();
    _fullWidthController.dispose();
  }

  double get width => _widthAnimation.value;

  double get fullWidth => _fullWidthAnimation.value;

  bool get isOpen => isExpanded || isMaximized;

  bool get isExpanded => _state == _ControllerState.expanded;

  bool get isMaximized => _state == _ControllerState.maximized;
}

/// Modal sheet that that can extend to a certain width and occupy this space but also overlap to the full screen width.
///
/// Modal sheet is controlled by [DASModalSheetController]
class DasModalSheet extends StatefulWidget {
  static const Key modalSheetClosedKey = Key('dasModalSheetClosed');
  static const Key modalSheetExtendedKey = Key('dasModalSheetExtended');
  static const Key modalSheetMaximizedKey = Key('dasModalSheetMaximized');
  static const Key modalSheetCloseButtonKey = Key('dasModalSheetCloseButton');

  const DasModalSheet({
    required this.builder,
    required this.controller,
    super.key,
    this.leftMargin = 0.0,
  });

  final DASModalSheetBuilder builder;
  final DASModalSheetController controller;

  /// margin used in full-screen on the left side of the modal sheet.
  final double leftMargin;

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
    // Flutter stack can't handle hits outside bounds: https://github.com/flutter/flutter/issues/31728
    return StackHitTestWithoutSizeLimit(
      clipBehavior: Clip.none,
      children: [
        // invisible widget used to extend stack width
        Container(width: min(widget.controller.maxExpandedWidth, modalWidth)),
        // visible modal sheet that can overlap stack and extend to full width
        Positioned(right: 0, top: 0, bottom: 0, child: _modalSheet(modalWidth)),
      ],
    );
  }

  Widget _modalSheet(double width) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    return ExtendedAppBarWrapper(
      child: Container(
        width: width,
        padding: EdgeInsets.all(sbbDefaultSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(sbbDefaultSpacing * 2)),
          color: isDarkTheme ? SBBColors.charcoal : SBBColors.white,
        ),
        child: widget.controller.isOpen
            ? _body()
            : SizedBox(key: DasModalSheet.modalSheetClosedKey, height: double.infinity),
      ),
    );
  }

  Widget _body() {
    return Column(
      key: widget.controller.isExpanded ? DasModalSheet.modalSheetExtendedKey : DasModalSheet.modalSheetMaximizedKey,
      mainAxisSize: MainAxisSize.max,
      children: [
        _header(),
        SizedBox(height: sbbDefaultSpacing * 0.5),
        Expanded(child: widget.builder.body(context)),
      ],
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: widget.builder.header(context) ?? SizedBox(),
        ),
        SBBIconButtonLarge(
          key: DasModalSheet.modalSheetCloseButtonKey,
          onPressed: () => widget.controller.close(),
          icon: SBBIcons.cross_small,
        ),
      ],
    );
  }

  /// Returns width of modal with a max with of screen width - leftMargin
  double _calculateModalWidth(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - widget.leftMargin;
    final animatedWidthOfController = widget.controller.width + (widget.controller.fullWidth * maxWidth);
    return min(animatedWidthOfController, maxWidth);
  }
}

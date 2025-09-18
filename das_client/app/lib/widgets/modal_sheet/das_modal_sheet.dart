import 'dart:async';
import 'dart:math';

import 'package:app/di/di.dart';
import 'package:app/util/animation.dart';
import 'package:app/util/time_constants.dart';
import 'package:app/widgets/extended_header_container.dart';
import 'package:extra_hittest_area/extra_hittest_area.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

enum _ControllerState { closed, expanded, maximized }

/// Used to build header and body widgets for [DasModalSheet]
class DASModalSheetBuilder {
  Widget? header(BuildContext context) => null;

  Widget body(BuildContext context) => SizedBox.shrink();
}

final _log = Logger('DASModalSheetController');

/// Used to open and close the [DasModalSheet] and handle animation.
class DASModalSheetController {
  final _automaticCloseAfterSeconds = DI.get<TimeConstants>().modalSheetAutomaticCloseAfterSeconds;

  DASModalSheetController({
    this.openAnimationDuration = const Duration(milliseconds: 350),
    this.closeAnimationDuration = const Duration(milliseconds: 200),
    this.maxExpandedWidth = 300.0,
    this.onClose,
    this.onOpen,
  }) : _state = _ControllerState.closed;

  final Duration openAnimationDuration;
  final Duration closeAnimationDuration;

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
    _controller = AnimationController(
      vsync: vsync,
      duration: openAnimationDuration,
      reverseDuration: closeAnimationDuration,
    );
    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: maxExpandedWidth,
    ).animate(_controller.toEmphasizedEasingAnimation())..addListener(() => onUpdate?.call());

    _fullWidthController = AnimationController(
      vsync: vsync,
      duration: openAnimationDuration,
      reverseDuration: closeAnimationDuration,
    );
    _fullWidthAnimation = Tween<double>(begin: 0, end: 1).animate(_fullWidthController.toEmphasizedEasingAnimation())
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

    if (_state == _ControllerState.closed) {
      onOpen?.call();
    }

    if (_state != _ControllerState.maximized) {
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
      _idleTimer = Timer(Duration(seconds: _automaticCloseAfterSeconds), () {
        if (isOpen) {
          _log.fine(
            'Screen idle time of $_automaticCloseAfterSeconds seconds reached. Closing DAS modal sheet.',
          );
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
      mainAxisSize: MainAxisSize.max,
      children: [
        _keyIdentifier(),
        _header(),
        SizedBox(height: sbbDefaultSpacing * 0.5),
        Expanded(child: widget.builder.body(context)),
      ],
    );
  }

  Widget _header() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 64.0),
      child: Row(
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
      ),
    );
  }

  /// Returns width of modal with a max with of screen width - leftMargin
  double _calculateModalWidth(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - widget.leftMargin;
    final animatedWidthOfController = widget.controller.width + (widget.controller.fullWidth * maxWidth);
    return min(animatedWidthOfController, maxWidth);
  }

  /// separate widget as otherwise the whole sheet will be redrawn after animation because the key changes
  Widget _keyIdentifier() {
    return SizedBox.shrink(
      key: widget.controller.isExpanded ? DasModalSheet.modalSheetExtendedKey : DasModalSheet.modalSheetMaximizedKey,
    );
  }
}

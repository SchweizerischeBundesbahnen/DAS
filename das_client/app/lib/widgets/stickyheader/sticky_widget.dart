import 'dart:async';
import 'dart:math';

import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/stickyheader/sticky_widget_controller.dart';
import 'package:flutter/material.dart';

class StickyWidget extends StatefulWidget {
  final StickyWidgetController controller;
  final StickyWidgetBuilder widgetBuilder;
  final bool isHeader;
  final Stream<ThemeMode>? themeModeStream;

  const StickyWidget({
    required this.controller,
    required this.widgetBuilder,
    this.isHeader = true,
    this.themeModeStream,
    super.key,
  });

  @override
  State<StickyWidget> createState() => _StickyWidgetState();
}

class _StickyWidgetState extends State<StickyWidget> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  Widget? _stickyHeader1;
  Widget? _stickyHeader2;
  Widget? _stickyFooter;
  StreamSubscription<ThemeMode>? _themeSub;

  int _epoch = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController.unbounded(vsync: this);
    _animationController.addListener(() {
      if (widget.controller.scrollController.positions.isNotEmpty) {
        widget.controller.scrollController.position.jumpTo(_animationController.value);
      }
    });
    widget.controller.addListener(_update);
    _subscribeTheme();
  }

  @override
  void didUpdateWidget(covariant StickyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
    if (widget.themeModeStream != oldWidget.themeModeStream) {
      _unsubscribeTheme();
      _subscribeTheme();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.controller.removeListener(_update);
    _unsubscribeTheme();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _onThemeChanged(null);
  }

  void _subscribeTheme() {
    final stream = widget.themeModeStream;
    if (stream == null) return;
    _themeSub = stream.distinct().listen(_onThemeChanged, onError: (_) {});
  }

  void _unsubscribeTheme() {
    _themeSub?.cancel();
    _themeSub = null;
  }

  void _onThemeChanged(ThemeMode? _) {
    if (!mounted) return;
    _animationController.stop();
    _stickyHeader1 = null;
    _stickyHeader2 = null;
    _stickyFooter = null;
    _epoch++;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(_epoch),
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: widget.isHeader ? _buildHeaders(context) : _buildFooter(context),
      ),
    );
  }

  Widget _buildHeaders(BuildContext context) {
    _buildHeaderWidgets(context);
    return Stack(
      children: [
        if (_stickyHeader2 != null) _stickyHeader2!,
        if (_stickyHeader1 != null) _stickyHeader1!,
      ],
    );
  }

  void _buildHeaderWidgets(BuildContext context) {
    final indexesToBuild = widget.controller.headerIndexes;
    if (!widget.controller.isRecalculating) {
      if (indexesToBuild[StickyLevel.first] != -1) {
        _stickyHeader1 = Positioned(
          left: 0,
          top: widget.controller.headerOffsets[StickyLevel.first],
          right: 0,
          child: widget.widgetBuilder(context, indexesToBuild[StickyLevel.first]!),
        );
      } else {
        _stickyHeader1 = null;
      }
      if (indexesToBuild[StickyLevel.second] != -1) {
        _stickyHeader2 = Positioned(
          left: 0,
          top:
              widget.controller.widgetHeight(indexesToBuild[StickyLevel.first]!) +
              widget.controller.headerOffsets[StickyLevel.second]!,
          right: 0,
          child: widget.widgetBuilder(context, indexesToBuild[StickyLevel.second]!),
        );
      } else {
        _stickyHeader2 = null;
      }
    }
  }

  void _buildFooterWidget(BuildContext context) {
    final indexToBuild = widget.controller.footerIndex;
    if (!widget.controller.isRecalculating) {
      if (indexToBuild != -1) {
        _stickyFooter = widget.widgetBuilder(context, indexToBuild);
      } else {
        _stickyFooter = null;
      }
    }
  }

  Widget _buildFooter(BuildContext context) {
    _buildFooterWidget(context);
    if (_stickyFooter == null) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _stickyFooter!,
        ),
      ],
    );
  }

  void _update() {
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.controller.scrollController.positions.isNotEmpty) {
      widget.controller.scrollController.position.jumpTo(
        max(widget.controller.scrollController.position.pixels - details.delta.dy, 0),
      );
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.controller.scrollController.positions.isNotEmpty) {
      final scrollPosition = widget.controller.scrollController.position;
      final velocity = details.velocity.clampMagnitude(0, 1000).pixelsPerSecond.dy;
      final simulation = scrollPosition.physics.createBallisticSimulation(scrollPosition, velocity);
      if (simulation != null) {
        _animationController.animateWith(simulation);
      }
    }
  }
}

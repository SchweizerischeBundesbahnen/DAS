// Copyright (c) 2022, crasowas.
//
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:das_client/app/widgets/stickyheader/sticky_header.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_widget_controller.dart';
import 'package:flutter/material.dart';

/// Sticky Widget.
///
/// Adjusts the position and visibility of the widget in real time according to
/// the scrolling changes, while covering the lower widget to achieve the effect
/// of sticky header.
class StickyWidget extends StatefulWidget {
  final StickyWidgetController controller;
  final StickyWidgetBuilder widgetBuilder;
  final bool isHeader;

  const StickyWidget({
    required this.controller,
    required this.widgetBuilder,
    this.isHeader = true,
    super.key,
  });

  @override
  State<StickyWidget> createState() => _StickyWidgetState();
}

class _StickyWidgetState extends State<StickyWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);
    _animationController.addListener(() {
      widget.controller.scrollController.position.jumpTo(_animationController.value);
    });
    widget.controller.addListener(_update);
  }

  @override
  void didUpdateWidget(covariant StickyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_update);
      widget.controller.addListener(_update);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: _buildSticky(context),
    );
  }

  Widget _buildSticky(BuildContext context) {
    final indexToBuild = widget.isHeader ? widget.controller.headerIndex : widget.controller.footerIndex;

    if (indexToBuild != -1) {
      return Stack(
        children: [
          Positioned(
              left: 0,
              top: widget.isHeader ? widget.controller.headerOffset : null,
              right: 0,
              bottom: widget.isHeader ? null : 0,
              child: widget.widgetBuilder(context, indexToBuild)),
        ],
      );
    }
    return Container();
  }

  void _update() {
    setState(() {});
  }

  /// The sticky widget should be scrollable so it feels like part of the scrolling widget.
  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.controller.scrollController.positions.isNotEmpty) {
      widget.controller.scrollController.position
          .jumpTo(widget.controller.scrollController.position.pixels - details.delta.dy);
    }
  }

  /// After the user stops dragging the sticky header widget, keep the same physics animation as the scrolling widget.
  void _onPanEnd(DragEndDetails details) {
    if (widget.controller.scrollController.positions.isNotEmpty) {
      final scrollPosition = widget.controller.scrollController.position;
      // Velocity limit.
      final velocity = details.velocity.clampMagnitude(0, 1000).pixelsPerSecond.dy;
      final simulation = scrollPosition.physics.createBallisticSimulation(scrollPosition, velocity);
      // In some cases, physical animation is not required, for example,
      // the velocity is already 0.0 at this time.
      if (simulation != null) {
        _animationController.animateWith(simulation);
      }
    }
  }
}

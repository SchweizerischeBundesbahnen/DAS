// Copyright (c) 2022, crasowas.
//
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:das_client/app/widgets/stickyheader/sticky_header.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_header_controller.dart';
import 'package:flutter/material.dart';

/// Sticky Header Widget.
///
/// Adjusts the position and visibility of the widget in real time according to
/// the scrolling changes, while covering the lower widget to achieve the effect
/// of sticky header.
class StickyWidget extends StatefulWidget {
  final StickyHeaderController controller;
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

  /// The sticky header widget should be scrollable, and the scrolling widget
  /// scrolls in sync when the sticky header widget scrolls,
  /// it feels like part of the scrolling widget.
  void _onPanUpdate(DragUpdateDetails details) {}

  /// After the user stops dragging the sticky header widget, keep the same
  /// physics animation as the scrolling widget.
  void _onPanEnd(DragEndDetails details) {}
}

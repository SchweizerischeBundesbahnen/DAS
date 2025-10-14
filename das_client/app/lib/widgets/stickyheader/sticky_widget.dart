// Copyright (c) 2022, crasowas.
//
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/stickyheader/sticky_widget_controller.dart';
import 'package:flutter/gestures.dart';
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
  Drag? _activeDrag;

  Widget? _stickyHeader1;
  Widget? _stickyHeader2;
  Widget? _stickyFooter;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);
    _animationController.addListener(() {
      _scrollController.position.jumpTo(_animationController.value);
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
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onVerticalDragCancel: _onVerticalDragCancel,
      child: widget.isHeader ? _buildHeaders(context) : _buildFooter(context),
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

    if (_stickyFooter == null) return SizedBox.shrink();

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

  void _update() => setState(() {});

  void _onVerticalDragStart(DragStartDetails details) {
    if (_scrollController.hasClients && _activeDrag == null) {
      _activeDrag = _scrollController.position.drag(details, () => _activeDrag = null);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) => _activeDrag?.update(details);

  void _onVerticalDragEnd(DragEndDetails details) {
    _activeDrag?.end(details);
    _activeDrag = null;
  }

  void _onVerticalDragCancel() {
    _activeDrag?.cancel();
    _activeDrag = null;
  }

  ScrollController get _scrollController => widget.controller.scrollController;
}

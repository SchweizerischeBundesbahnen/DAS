// Copyright (c) 2022, crasowas.
//
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:das_client/app/widgets/stickyheader/sticky_header_controller.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_widget.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

typedef StickyWidgetBuilder = Widget Function(BuildContext context, int index);

class StickyHeader extends StatefulWidget {
  final ScrollController scrollController;
  final StickyWidgetBuilder headerBuilder;
  final StickyWidgetBuilder? footerBuilder;
  final List<DASTableRow> rows;
  final Widget child;

  const StickyHeader({
    required this.headerBuilder,
    required this.child,
    required this.scrollController,
    required this.rows,
    this.footerBuilder,
    super.key,
  });

  @override
  State<StickyHeader> createState() => _StickyHeaderState();
}

class _StickyHeaderState extends State<StickyHeader> {
  late StickyHeaderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StickyHeaderController(
      scrollController: widget.scrollController,
      rows: widget.rows,
    );
  }

  @override
  void didUpdateWidget(covariant StickyHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rows != oldWidget.rows) {
      _controller.updateRowData(widget.rows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        widget.child,
        StickyWidget(
          controller: _controller,
          widgetBuilder: widget.headerBuilder,
        ),
        if (widget.footerBuilder != null)
          StickyWidget(
            controller: _controller,
            widgetBuilder: widget.footerBuilder!,
            isHeader: false,
          )
      ],
    );
  }
}

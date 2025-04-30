// Copyright (c) 2022, crasowas.
//
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:app/app/widgets/stickyheader/sticky_widget.dart';
import 'package:app/app/widgets/stickyheader/sticky_widget_controller.dart';
import 'package:app/app/widgets/table/das_table_row.dart';
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
  State<StickyHeader> createState() => StickyHeaderState();

  static StickyHeaderState? of(BuildContext context) {
    return context.findAncestorStateOfType<StickyHeaderState>();
  }
}

class StickyHeaderState extends State<StickyHeader> {
  late StickyWidgetController controller;
  final GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    controller = StickyWidgetController(
      stickyHeaderKey: key,
      scrollController: widget.scrollController,
      rows: widget.rows,
    );
  }

  @override
  void didUpdateWidget(covariant StickyHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rows != oldWidget.rows) {
      controller.updateRowData(widget.rows);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: key,
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        NotificationListener<ScrollEndNotification>(
            onNotification: (scrollEnd) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.scrollListener();
              });
              return false;
            },
            child: widget.child),
        StickyWidget(
          controller: controller,
          widgetBuilder: widget.headerBuilder,
        ),
        if (widget.footerBuilder != null)
          StickyWidget(
            controller: controller,
            widgetBuilder: widget.footerBuilder!,
            isHeader: false,
          )
      ],
    );
  }
}

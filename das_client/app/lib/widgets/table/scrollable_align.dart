import 'dart:math';

import 'package:app/util/widget_util.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

final _log = Logger('ScrollableAlign');

class ScrollableAlign extends StatefulWidget {
  const ScrollableAlign({required this.rows, required this.scrollController, required this.child, super.key});

  final Widget child;
  final List<DASTableRow> rows;
  final ScrollController scrollController;

  @override
  State<ScrollableAlign> createState() => _ScrollableAlignState();
}

class _ScrollableAlignState extends State<ScrollableAlign> {
  static const Duration alignScrollDuration = Duration(milliseconds: 300);
  final GlobalKey key = GlobalKey();
  bool isTouching = false;
  bool isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      key: key,
      onPointerDown: (_) {
        isTouching = true;
      },
      onPointerUp: (_) {
        isTouching = false;
      },
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          // Delay scroll back by 1 Frame to avoid strange behaviour
          if (!isTouching && !isAnimating) {
            Future.delayed(Duration(milliseconds: 1), () => alignToElement());
          }
          return false;
        },
        child: widget.child,
      ),
    );
  }

  void alignToElement() async {
    final widgetOffset = WidgetUtil.findOffsetOfKey(key);
    final stickyHeaderState = StickyHeader.of(context);

    if (widget.scrollController.positions.isEmpty || widgetOffset == null || stickyHeaderState == null) {
      return;
    }

    var stickyHeaderHeight = 0.0;
    var stickyHeader2Offset = 0.0;
    final headerIndexes = stickyHeaderState.controller.headerIndexes;
    if (headerIndexes[StickyLevel.first] != -1) {
      stickyHeaderHeight += widget.rows[headerIndexes[StickyLevel.first]!].height;
    }
    if (headerIndexes[StickyLevel.second] != -1) {
      final rowHeight = widget.rows[headerIndexes[StickyLevel.second]!].height;
      final stickyOffset = stickyHeaderState.controller.headerOffsets[StickyLevel.second]!.abs();
      if (rowHeight >= stickyOffset) {
        stickyHeader2Offset = min(stickyOffset, rowHeight);
        stickyHeaderHeight += rowHeight - stickyOffset;
      }
    }
    stickyHeaderHeight = stickyHeaderHeight.roundToDouble();

    final currentPosition = widget.scrollController.position.pixels;

    if (stickyHeader2Offset > 0) {
      _scrollToTarget((currentPosition - stickyHeader2Offset).roundToDouble());
      return;
    }

    for (int i = 0; i < widget.rows.length; i++) {
      final row = widget.rows[i];
      if (row.key.currentContext != null) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        if (renderObject != null) {
          final offset = renderObject.localToGlobal(Offset.zero) - widgetOffset;
          final visibleArea = offset.dy + row.height - stickyHeaderHeight;

          if (visibleArea == row.height) {
            break;
          }

          if (visibleArea > 0) {
            _scrollToTarget((currentPosition - (row.height - visibleArea)).roundToDouble());
            break;
          }
        }
      }
    }
  }

  Future<void> _scrollToTarget(double targetPosition) async {
    if (widget.scrollController.position.pixels != targetPosition) {
      _log.fine(
        'Scrolling to targetPosition=$targetPosition, currentPosition=${widget.scrollController.position.pixels}',
      );
      isAnimating = true;
      await widget.scrollController.animateTo(targetPosition, duration: alignScrollDuration, curve: Curves.easeInOut);
      isAnimating = false;
    }
  }
}

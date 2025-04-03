import 'package:das_client/app/widgets/stickyheader/sticky_header.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/util/widget_util.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/cupertino.dart';

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
          onNotification: (scrollEnd) {
            // Delay scroll back by 1 Frame to avoid strange behaviour
            Future.delayed(Duration(milliseconds: 1), () {
              if (!isTouching && !isAnimating) {
                alignToElement();
              }
            });
            return true;
          },
          child: widget.child),
    );
  }

  void alignToElement() async {
    final widgetOffset = WidgetUtil.findOffsetOfKey(key);
    final stickyHeaderState = StickyHeader.of(context);

    if (widget.scrollController.positions.isEmpty || widgetOffset == null || stickyHeaderState == null) {
      return;
    }

    final stickyHeaderHeight = stickyHeaderState.controller.stickyHeaderHeight;
    final currentPosition = widget.scrollController.position.pixels;

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
            _scrollToTarget(currentPosition - (row.height - visibleArea));
            break;
          }
        }
      }
    }

    /*

    final stickyHeaderHeightAdjustment = {StickyLevel.first: 0.0, StickyLevel.second: 0.0};
    var itemStart = 0.0;

    for (var i = 0; i < widget.rows.length; i++) {
      final item = widget.rows[i];

      if (item.stickyLevel == StickyLevel.first) {
        stickyHeaderHeightAdjustment[StickyLevel.first] = item.height;
      } else if (item.stickyLevel == StickyLevel.second) {
        stickyHeaderHeightAdjustment[StickyLevel.second] = item.height;
      }

      final itemEnd = itemStart + item.height;
      var adjustedCurrentPosition = currentPosition + stickyHeaderHeightAdjustment.values.sum;
      if (adjustedCurrentPosition >= itemStart && adjustedCurrentPosition < itemEnd) {
        _scrollToTarget(itemStart - stickyHeaderHeightAdjustment.values.sum);
        break;
      }

      if (item.stickyLevel == StickyLevel.first) {
        stickyHeaderHeightAdjustment[StickyLevel.second] = 0;

        // Need to check alignment again once second sticky header is removed
        adjustedCurrentPosition = currentPosition + stickyHeaderHeightAdjustment.values.sum;
        if (adjustedCurrentPosition >= itemStart && adjustedCurrentPosition < itemEnd) {
          _scrollToTarget(itemStart - stickyHeaderHeightAdjustment.values.sum);
          break;
        }
      }
      itemStart = itemEnd;
    }

     */
  }

  Future<void> _scrollToTarget(double targetPosition) async {
    if (widget.scrollController.position.pixels != targetPosition) {
      Fimber.d(
          'Scrolling to targetPosition=$targetPosition, currentPosition=${widget.scrollController.position.pixels}');
      isAnimating = true;
      await widget.scrollController.animateTo(targetPosition, duration: alignScrollDuration, curve: Curves.easeInOut);
      isAnimating = false;
    }
  }
}

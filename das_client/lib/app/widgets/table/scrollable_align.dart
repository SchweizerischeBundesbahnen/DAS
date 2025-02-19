import 'package:collection/collection.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
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
  static const Duration alignScrollDuration = Duration(milliseconds: 3000);
  bool isTouching = false;
  bool isAnimating = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
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
    if (widget.scrollController.positions.isEmpty) {
      return;
    }

    final currentPosition = widget.scrollController.position.pixels;
    var itemStart = 0.0;
    var stickyHeaderHeightAdjustment = widget.rows.firstWhereOrNull((it) => it.isSticky)?.height ?? 0;
    for (var i = 0; i < widget.rows.length; i++) {
      final item = widget.rows[i];

      final itemEnd = itemStart + item.height;
      final adjustedCurrentPosition = currentPosition + stickyHeaderHeightAdjustment;
      if (adjustedCurrentPosition >= itemStart && adjustedCurrentPosition < itemEnd) {
        final targetPosition = itemStart - stickyHeaderHeightAdjustment;
        if (currentPosition != targetPosition) {
          Fimber.d('Aligning to item with index=$i, targetPosition=$targetPosition, currentPosition=$currentPosition');
          isAnimating = true;
          await widget.scrollController
              .animateTo(targetPosition, duration: alignScrollDuration, curve: Curves.easeInOut);
          isAnimating = false;
        }
        break;
      }

      if (item.isSticky) {
        stickyHeaderHeightAdjustment = item.height;
      }
      itemStart = itemEnd;
    }
  }
}

import 'dart:math';

import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/row/das_table_row_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';

final _log = Logger('JourneyTableScrollController');

/// Responsible for scrolling the [JourneyTable] to a specific JourneyPosition.
///
/// Use [scrollToJourneyPoint].
///
/// Reads the target row's position directly from the render tree so that the
/// calculation is always accurate regardless of row height changes or frame
/// ordering — no height summation is needed.
class JourneyTableScrollController {
  static const int _minScrollDuration = 1000;
  static const int _maxScrollDuration = 2000;

  JourneyTableScrollController({ScrollController? controller, GlobalKey? tableKey})
    : scrollController = controller ?? ScrollController(),
      tableKey = tableKey ?? GlobalKey();

  final ScrollController scrollController;
  final GlobalKey tableKey;
  List<DASTableRowBuilder> _renderedRows = [];
  bool _isDisposed = false;

  void updateRenderedRows(List<DASTableRowBuilder> rows) => _renderedRows = rows;

  void scrollToJourneyPoint(JourneyPoint? target) {
    if (_isDisposed) return;

    // Defer by one frame so the layout for the current build is fully committed
    // before reading RenderBox positions.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      final targetPosition = _calculateTargetPosition(target);
      if (targetPosition != null) {
        _scrollToPosition(targetPosition);
      }
    });
  }

  void dispose() {
    _isDisposed = true;
  }

  double? _calculateTargetPosition(JourneyPoint? targetPoint) {
    if (targetPoint == null || scrollController.positions.isEmpty) {
      return null;
    }

    final targetRow = _renderedRows.firstWhereOrNull((it) => it.data == targetPoint);
    if (targetRow == null) {
      _log.warning('Target journey point not found in rendered rows');
      return null;
    }

    final targetRenderObject = targetRow.key.currentContext?.findRenderObject() as RenderBox?;
    final tableRenderObject = tableKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetRenderObject == null || tableRenderObject == null) {
      _log.warning(
        'Failed to find render objects: targetRenderObject=$targetRenderObject, tableRenderObject=$tableRenderObject',
      );
      return null;
    }

    // Distance from the table's top (below the fixed header) to the
    // target row's top, **as currently painted**.
    final distanceFromTableTop =
        targetRenderObject.localToGlobal(Offset.zero).dy -
        tableRenderObject.localToGlobal(Offset.zero).dy -
        DASTable.headerRowHeight;

    final stickyHeight = _calculateStickyHeight(targetPoint);

    _log.fine(
      'currentPixels: ${scrollController.position.pixels}, '
      'distanceFromTableTop: $distanceFromTableTop, stickyHeight: $stickyHeight',
    );

    // Shift the scroll position so the target row sits flush at the top of
    // the visible content area, just below any sticky header above it.
    return scrollController.position.pixels + distanceFromTableTop - stickyHeight;
  }

  void _scrollToPosition(double targetScrollPosition) {
    _log.finer('Scrolling to position $targetScrollPosition');
    scrollController.animateTo(
      targetScrollPosition,
      duration: _calculateDuration(targetScrollPosition),
      curve: Curves.easeInOut,
    );
  }

  Duration _calculateDuration(double targetPosition) {
    final linearDuration = ((targetPosition - scrollController.offset).abs()).floor();
    final boundedDuration = min(max(_minScrollDuration, linearDuration), _maxScrollDuration);
    return Duration(milliseconds: boundedDuration);
  }

  /// Returns the combined height of sticky headers that sit above [data] in
  /// the row list, so the scroll target is placed below them.
  double _calculateStickyHeight(JourneyPoint data) {
    final stickyHeaderHeights = {StickyLevel.first: 0.0, StickyLevel.second: 0.0};

    for (final row in _renderedRows) {
      if (data == row.data) {
        if (row.stickyLevel == .none) {
          return stickyHeaderHeights.values.sum;
        } else if (row.stickyLevel == .second) {
          return stickyHeaderHeights[StickyLevel.first]!;
        } else {
          return 0.0;
        }
      }

      if (row.stickyLevel == .first) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        stickyHeaderHeights[.first] = renderObject?.size.height ?? row.height;
        stickyHeaderHeights[.second] = 0.0;
      } else if (row.stickyLevel == .second) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        stickyHeaderHeights[.second] = renderObject?.size.height ?? row.height;
      }
    }

    return 0.0;
  }
}

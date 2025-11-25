import 'dart:math';

import 'package:app/util/widget_util.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

class StickyWidgetController with ChangeNotifier {
  StickyWidgetController({
    required this.stickyHeaderKey,
    required this.scrollController,
    required List<DASTableRow> rows,
  }) : _rows = rows {
    scrollController.addListener(scrollListener);
    _initialize();
  }

  final GlobalKey stickyHeaderKey;
  final ScrollController scrollController;
  List<DASTableRow> _rows;
  bool _recalculating = false;

  Map<StickyLevel, double> headerOffsets = {.first: 0.0, .second: 0.0};
  Map<StickyLevel, int> headerIndexes = {.first: -1, .second: -1};
  Map<StickyLevel, int> nextHeaderIndex = {.first: -1, .second: -1};

  var footerIndex = -1;

  bool get isRecalculating => _recalculating;

  void _initialize() {
    _recalculating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollListener();
    });
  }

  void updateRowData(List<DASTableRow> rows) {
    _rows = rows;
    _initialize();
  }

  void scrollListener() {
    final firstVisibleIndex = _findFirstVisibleRowIndex();
    if (firstVisibleIndex == -1) {
      _recalculating = true;
      return;
    }

    headerIndexes = {.first: -1, .second: -1};
    footerIndex = -1;

    if (scrollController.positions.isNotEmpty) {
      _calculateHeaders(firstVisibleIndex);
      _calculateNextHeaderIndex();
      _calculateHeaderOffsets();
      footerIndex = _calculateFooter(headerIndexes[StickyLevel.first]! + 1);
    }

    _recalculating = false;
    notifyListeners();
  }

  Offset? stickyHeaderOffset() {
    return WidgetUtil.findOffsetOfKey(stickyHeaderKey);
  }

  int _findFirstVisibleRowIndex() {
    final stickyOffset = stickyHeaderOffset();
    if (stickyOffset == null) return -1;

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
      if (renderObject != null) {
        final offset = renderObject.localToGlobal(Offset.zero) - stickyOffset;
        if (offset.dy + row.height > 0) {
          return i;
        }
      }
    }
    return -1;
  }

  void _calculateHeaders(int startIndex) {
    for (int i = startIndex; i >= 0; i--) {
      final stickyLevel = _rows[i].stickyLevel;
      if (stickyLevel == .first) {
        headerIndexes[stickyLevel] = i;
        break;
      }
    }

    final firstHeaderIndex = headerIndexes[StickyLevel.first]!;
    if (firstHeaderIndex != -1) {
      for (int i = startIndex + 1; i >= firstHeaderIndex; i--) {
        if (i < _rows.length) {
          final stickyLevel = _rows[i].stickyLevel;
          if (stickyLevel == .second) {
            headerIndexes[stickyLevel] = i;
            break;
          }
        }
      }
    }
  }

  void _calculateHeaderOffsets() {
    final firstHeaderHeight = headerIndexes[StickyLevel.first] != -1
        ? _rows[headerIndexes[StickyLevel.first]!].height
        : 0.0;

    headerOffsets = {
      .first: _calculateHeaderOffset(headerIndexes[StickyLevel.first]!, .first, 0.0),
      .second: _calculateHeaderOffset(headerIndexes[StickyLevel.second]!, .second, firstHeaderHeight),
    };
  }

  double _calculateHeaderOffset(int headerIndex, StickyLevel stickyLevel, double additionalHeaderHeight) {
    final stickyOffset = stickyHeaderOffset();
    if (stickyOffset == null) return 0.0;

    final nextStickyIndex = _findNextStickyBelowLevel(headerIndex + 1, stickyLevel);
    if (headerIndex != -1 && nextStickyIndex != -1) {
      final offset = WidgetUtil.findOffsetOfKey(_rows[nextStickyIndex].key);
      if (offset != null) {
        final localOffset = offset - stickyOffset;
        return min(0.0, localOffset.dy - _rows[headerIndex].height - additionalHeaderHeight);
      }
    }

    return 0.0;
  }

  int _calculateFooter(int startIndex) {
    var stickyFooterIndex = _findNextStickyBelowLevel(startIndex, .first);

    if (stickyFooterIndex != -1) {
      final stickyOffset = stickyHeaderOffset();
      final offset = WidgetUtil.findOffsetOfKey(_rows[stickyFooterIndex].key);
      if (offset != null &&
          (offset - stickyOffset!).dy + _rows[stickyFooterIndex].height < scrollController.position.viewportDimension) {
        // Footer is already on screen
        stickyFooterIndex = -1;
      }
    }
    return stickyFooterIndex;
  }

  int _findNextStickyBelowLevel(int startIndex, StickyLevel stickyLevel) {
    for (int i = startIndex; i < _rows.length; i++) {
      if (_rows[i].stickyLevel != .none && _rows[i].stickyLevel.index <= stickyLevel.index) return i;
    }
    return -1;
  }

  double widgetHeight(int index) {
    if (index < 0 || index >= _rows.length) return 0.0;
    return _rows[index].height;
  }

  void _calculateNextHeaderIndex() {
    nextHeaderIndex = {
      .first: _findNextStickyBelowLevel(headerIndexes[StickyLevel.first]! + 1, .first),
      .second: _findNextStickyBelowLevel(headerIndexes[StickyLevel.second]! + 1, .second),
    };
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }
}

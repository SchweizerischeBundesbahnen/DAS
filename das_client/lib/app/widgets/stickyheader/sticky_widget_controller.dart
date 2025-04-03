import 'dart:math';

import 'package:collection/collection.dart';
import 'package:das_client/app/widgets/stickyheader/sticky_level.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:das_client/util/widget_util.dart';
import 'package:flutter/material.dart';

class StickyWidgetController with ChangeNotifier {
  StickyWidgetController(
      {required this.stickyHeaderKey, required this.scrollController, required List<DASTableRow> rows})
      : _rows = rows {
    scrollController.addListener(_scrollListener);
    _initialize();
  }

  final GlobalKey stickyHeaderKey;
  final ScrollController scrollController;
  final List<double> rowOffsets = [];
  List<DASTableRow> _rows;

  Map<StickyLevel, double> headerOffsets = {
    StickyLevel.first: 0.0,
    StickyLevel.second: 0.0,
  };
  Map<StickyLevel, int> headerIndexes = {
    StickyLevel.first: -1,
    StickyLevel.second: -1,
  };
  var footerIndex = -1;

  void _initialize() {
    var offset = 0.0;
    for (var i = 0; i < _rows.length; i++) {
      rowOffsets.add(offset);
      offset += _rows[i].height;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollListener();
    });
  }

  void _scrollListener() {
    final firstVisibleIndex = findFirstVisibleRowIndex();
    if (firstVisibleIndex == -1) {
      return;
    }

    headerIndexes = {
      StickyLevel.first: -1,
      StickyLevel.second: -1,
    };
    footerIndex = -1;

    if (scrollController.positions.isNotEmpty) {
      final currentPixels = scrollController.position.pixels;

      _calculateHeaders(firstVisibleIndex);
      _calculateHeaderOffsets();
      footerIndex = _calculateFooter(headerIndexes[StickyLevel.first]! + 1, currentPixels);
    }

    notifyListeners();
  }

  int findFirstVisibleRowIndex() {
    final stickyOffset = WidgetUtil.findOffsetOfKey(stickyHeaderKey);
    if (stickyOffset == null) return -1;

    for (int i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      if (row.key.currentContext != null) {
        final renderObject = row.key.currentContext?.findRenderObject() as RenderBox?;
        if (renderObject != null) {
          final offset = renderObject.localToGlobal(Offset.zero) - stickyOffset;
          if (offset.dy + row.height > 0) {
            return i;
          }
        }
      }
    }
    return -1;
  }

  void _calculateHeaders(int startIndex) {
    for (int i = startIndex; i >= 0; i--) {
      final stickyLevel = _rows[i].stickyLevel;
      if (stickyLevel == StickyLevel.first) {
        headerIndexes[stickyLevel] = i;
        break;
      }
    }

    final firstHeaderIndex = headerIndexes[StickyLevel.first]!;
    if (firstHeaderIndex != -1) {
      for (int i = startIndex + 1; i >= firstHeaderIndex; i--) {
        if (i < _rows.length) {
          final stickyLevel = _rows[i].stickyLevel;
          if (stickyLevel == StickyLevel.second) {
            headerIndexes[stickyLevel] = i;
            break;
          }
        }
      }
    }
  }

  void _calculateHeaderOffsets() {
    final firstHeaderHeight =
        headerIndexes[StickyLevel.first] != -1 ? _rows[headerIndexes[StickyLevel.first]!].height : 0.0;

    headerOffsets = {
      StickyLevel.first: _calculateHeaderOffset(headerIndexes[StickyLevel.first]!, StickyLevel.first, 0.0),
      StickyLevel.second:
          _calculateHeaderOffset(headerIndexes[StickyLevel.second]!, StickyLevel.second, firstHeaderHeight),
    };
  }

  double _calculateHeaderOffset(int headerIndex, StickyLevel stickyLevel, double additionalHeaderHeight) {
    final stickyOffset = WidgetUtil.findOffsetOfKey(stickyHeaderKey);
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

  int _calculateFooter(int startIndex, double currentPixels) {
    var stickyFooterIndex = _findNextStickyBelowLevel(startIndex, StickyLevel.first);

    if (stickyFooterIndex != -1) {
      final stickyOffset = rowOffsets[stickyFooterIndex];
      if (currentPixels + scrollController.position.viewportDimension >
          stickyOffset + _rows[stickyFooterIndex].height) {
        // Footer is already on screen
        stickyFooterIndex = -1;
      }
    }
    return stickyFooterIndex;
  }

  int _findNextStickyBelowLevel(int startIndex, StickyLevel stickyLevel) {
    for (int i = startIndex; i < _rows.length; i++) {
      if (_rows[i].stickyLevel != StickyLevel.none && _rows[i].stickyLevel.index <= stickyLevel.index) return i;
    }
    return -1;
  }

  double widgetHeight(int index) {
    if (index < 0 || index >= _rows.length) return 0.0;
    return _rows[index].height;
  }

  void updateRowData(List<DASTableRow> rows) {
    _rows = rows;
    rowOffsets.clear();
    _initialize();
    _scrollListener();
  }

  double get stickyHeaderHeight =>
      headerIndexes.entries.where((it) => it.value != -1).map((it) => _rows[it.value].height).sum;

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}

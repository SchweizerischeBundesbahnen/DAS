import 'package:das_client/app/widgets/stickyheader/sticky_level.dart';
import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

class StickyWidgetController with ChangeNotifier {
  StickyWidgetController({required this.scrollController, required List<DASTableRow> rows}) : _rows = rows {
    scrollController.addListener(_scrollListener);
    _initialize();
  }

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
    headerIndexes = {
      StickyLevel.first: -1,
      StickyLevel.second: -1,
    };
    footerIndex = -1;

    if (scrollController.positions.isNotEmpty) {
      final currentPixels = scrollController.position.pixels;
      for (int i = 0; i < rowOffsets.length; i++) {
        if (currentPixels >= rowOffsets[i] && currentPixels < rowOffsets[i] + _rows[i].height) {
          _calculateHeaders(i, currentPixels);
          _calculateHeaderOffsets(currentPixels);
          footerIndex = _calculateFooter(headerIndexes[StickyLevel.first]! + 1, currentPixels);
          break;
        }
      }
    }

    notifyListeners();
  }

  void _calculateHeaders(int startIndex, double currentPixels) {
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

  void _calculateHeaderOffsets(double currentPixels) {
    final firstHeaderHeight =
        headerIndexes[StickyLevel.first] != -1 ? _rows[headerIndexes[StickyLevel.first]!].height : 0.0;

    headerOffsets = {
      StickyLevel.first: _calculateHeaderOffset(headerIndexes[StickyLevel.first]!, currentPixels, StickyLevel.first),
      StickyLevel.second: _calculateHeaderOffset(
          headerIndexes[StickyLevel.second]!, currentPixels + firstHeaderHeight, StickyLevel.second),
    };
  }

  double _calculateHeaderOffset(int headerIndex, double currentPixels, StickyLevel stickyLevel) {
    final nextStickyIndex = _findNextStickyBelowLevel(headerIndex + 1, stickyLevel);
    if (headerIndex != -1 && nextStickyIndex != -1) {
      final headerHeight = _rows[headerIndex].height;
      final nextStickyOffset = rowOffsets[nextStickyIndex];

      if (currentPixels + headerHeight > nextStickyOffset) {
        return nextStickyOffset - currentPixels - headerHeight;
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

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }
}

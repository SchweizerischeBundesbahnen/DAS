import 'package:das_client/app/widgets/table/das_table_row.dart';
import 'package:flutter/material.dart';

class StickyHeaderController with ChangeNotifier {
  StickyHeaderController({required this.scrollController, required List<DASTableRow> rows}) : _rows = rows {
    scrollController.addListener(_scrollListener);
    _initialize();
  }

  final ScrollController scrollController;
  final List<double> rowOffsets = [];
  List<DASTableRow> _rows;

  var headerOffset = 0.0;
  var headerIndex = -1;
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
    headerIndex = -1;
    footerIndex = -1;

    if (scrollController.positions.isNotEmpty) {
      final currentPixels = scrollController.position.pixels;
      for (int i = 0; i < rowOffsets.length; i++) {
        if (currentPixels >= rowOffsets[i] && currentPixels < rowOffsets[i] + _rows[i].height) {
          headerIndex = _calculateHeader(i, currentPixels);
          headerOffset = _calculateHeaderOffset(headerIndex, currentPixels);
          footerIndex = _calculateFooter(headerIndex + 1, currentPixels);
          break;
        }
      }
    }

    notifyListeners();
  }

  int _calculateHeader(int startIndex, double currentPixels) {
    for (int i = startIndex; i >= 0; i--) {
      if (_rows[i].isSticky) {
        return rowOffsets[i] != currentPixels ? i : -1;
      }
    }
    return -1;
  }

  double _calculateHeaderOffset(int headerIndex, double currentPixels) {
    final nextStickyIndex = _findNextSticky(headerIndex + 1);
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
    var nextStickyIndex = _findNextSticky(startIndex);

    if (nextStickyIndex != -1) {
      final stickyOffset = rowOffsets[nextStickyIndex];
      if (currentPixels + scrollController.position.viewportDimension > stickyOffset + _rows[nextStickyIndex].height) {
        // Footer is already on screen
        nextStickyIndex = -1;
      }
    }
    return nextStickyIndex;
  }

  int _findNextSticky(int startIndex) {
    for (int i = startIndex; i < _rows.length; i++) {
      if (_rows[i].isSticky) return i;
    }
    return -1;
  }

  void updateRowData(List<DASTableRow> rows) {
    this._rows = rows;
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

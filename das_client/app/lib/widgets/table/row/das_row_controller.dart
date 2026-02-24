import 'package:app/util/widget_util.dart';
import 'package:app/widgets/stickyheader/sticky_widget_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DASRowController {
  DASRowController({required bool isAlwaysSticky, required GlobalKey rowKey, this.stickyController})
    : _rowKey = rowKey,
      _isAlwaysSticky = isAlwaysSticky {
    _rxRowState = BehaviorSubject<DASRowState>.seeded(isAlwaysSticky ? .sticky : .visible);
    _initListener();
  }

  late BehaviorSubject<DASRowState> _rxRowState;

  Stream<DASRowState> get rowState => _rxRowState.distinct();

  DASRowState get rowStateValue => _rxRowState.value;

  bool _isAlwaysSticky;

  bool get isAlwaysSticky => _isAlwaysSticky;

  final StickyWidgetController? stickyController;
  GlobalKey _rowKey;

  void _initListener() {
    stickyController?.removeListener(_stickyListener);
    if (stickyController != null && !_isAlwaysSticky) {
      stickyController!.addListener(_stickyListener);
    }
  }

  void updateIsAlwaysSticky(bool isAlwaysSticky) {
    if (_isAlwaysSticky != isAlwaysSticky) {
      _isAlwaysSticky = isAlwaysSticky;
      _rxRowState.add(isAlwaysSticky ? .sticky : .visible);
      _initListener();
    }
  }

  void updateRowKey(GlobalKey newRowKey) {
    if (_rowKey != newRowKey) {
      _rowKey = newRowKey;
      _stickyListener();
    }
  }

  void _stickyListener() {
    if (stickyController == null) return;

    if (isAlwaysSticky) {
      _rxRowState.add(.sticky);
      return;
    }

    final stickyOffset = stickyController!.stickyHeaderOffset();
    final rowOffset = WidgetUtil.findOffsetOfKey(_rowKey);
    if (stickyOffset == null || rowOffset == null) return;

    final stickyHeights = stickyController!.headerIndexes.values.map((it) => stickyController!.widgetHeight(it)).sum;
    final rowPosition = rowOffset.dy - stickyOffset.dy;

    if (rowPosition <= stickyHeights) {
      _rxRowState.add(.firstVisibleRow);
    } else {
      _rxRowState.add(.visible);
    }
  }

  void dispose() {
    _rxRowState.close();
    stickyController?.removeListener(_stickyListener);
  }
}

enum DASRowState {
  sticky,
  firstVisibleRow,
  visible,
}

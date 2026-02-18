import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/table/row/das_row_controller.dart';
import 'package:flutter/material.dart';

class DASRowControllerWrapper extends StatefulWidget {
  const DASRowControllerWrapper({
    required this.child,
    required this.rowKey,
    this.isAlwaysSticky = false,
    super.key,
  });

  final Widget child;
  final bool isAlwaysSticky;
  final GlobalKey rowKey;

  @override
  State<DASRowControllerWrapper> createState() => DASRowControllerWrapperState();

  static DASRowControllerWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<DASRowControllerWrapperState>();
  }
}

class DASRowControllerWrapperState extends State<DASRowControllerWrapper> {
  late DASRowController controller;

  @override
  void initState() {
    super.initState();
    controller = DASRowController(
      rowKey: widget.rowKey,
      isAlwaysSticky: widget.isAlwaysSticky,
      stickyController: StickyHeader.of(context)?.controller,
    );
  }

  @override
  void didUpdateWidget(covariant DASRowControllerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isAlwaysSticky != widget.isAlwaysSticky) {
      controller.updateIsAlwaysSticky(widget.isAlwaysSticky);
    }
    if (oldWidget.rowKey != widget.rowKey) {
      controller.updateRowKey(widget.rowKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

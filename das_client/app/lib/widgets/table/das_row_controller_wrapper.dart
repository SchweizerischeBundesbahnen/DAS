import 'package:app/widgets/table/das_row_controller.dart';
import 'package:flutter/material.dart';

class DASRowControllerWrapper extends StatefulWidget {
  const DASRowControllerWrapper({required this.child, this.isAlwaysSticky = false, super.key});

  final Widget child;
  final bool isAlwaysSticky;

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
    controller = DASRowController(isAlwaysSticky: widget.isAlwaysSticky);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

enum DASRowState {
  sticky,
  almostSticky,
  notSticky,
}

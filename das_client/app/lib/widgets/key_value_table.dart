import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class KeyValueTable extends StatelessWidget {
  const KeyValueTable({required this.rows, super.key});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SBBSpacing.xSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: rows,
      ),
    );
  }
}

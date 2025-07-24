import 'package:app/pages/journey/train_journey/das_table_speed_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineSpeedCellBody extends StatelessWidget {
  const LineSpeedCellBody({
    required this.rowIdentifier,
    super.key,
  });

  final int rowIdentifier;

  @override
  Widget build(BuildContext context) {
    final vm = context.read<DASTableSpeedViewModel>();
    return StreamBuilder(
      key: ValueKey(rowIdentifier),
      stream: vm.lineSpeedFor(rowIdentifier),
      initialData: vm.lineSpeedValueFor(rowIdentifier),
      builder: (context, snap) {
        if (!snap.hasData) return SizedBox.shrink();

        return Text(key: key, snap.data!.value);
      },
    );
  }
}

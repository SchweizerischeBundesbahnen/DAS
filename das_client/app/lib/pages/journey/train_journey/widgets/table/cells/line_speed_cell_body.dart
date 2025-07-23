import 'package:app/pages/journey/train_journey/das_table_speed_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineSpeedCellBody extends StatelessWidget {
  const LineSpeedCellBody({
    required this.rowIndex,
    super.key,
  });

  final int rowIndex;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.read<DASTableSpeedViewModel>().lineSpeedFor(rowIndex),
      builder: (context, snap) {
        if (!snap.hasData) return SizedBox.shrink();

        return Text(key: key, snap.data!.value);
      },
    );
  }
}

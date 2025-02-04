import 'package:flutter/material.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';


class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key});

  @override
  State<BatteryStatus> createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Battery status', style: DASTextStyles.largeRoman);
  }
}

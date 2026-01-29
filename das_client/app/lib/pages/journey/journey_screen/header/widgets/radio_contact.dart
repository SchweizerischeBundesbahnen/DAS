import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RadioContactChannels extends StatelessWidget {
  static const Key radioContactChannelsKey = Key('radioContactChannels');

  const RadioContactChannels({
    required this.mainContactIdentifiers,
    super.key,
  });

  final String? mainContactIdentifiers;

  @override
  Widget build(BuildContext context) => mainContactIdentifiers != null
      ? Text(
          key: radioContactChannelsKey,
          mainContactIdentifiers!,
          style: sbbTextStyle.romanStyle.xLarge,
          overflow: .ellipsis,
        )
      : SizedBox.shrink();
}

import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';

class RadioContactChannels extends StatelessWidget {
  static const Key radioContactChannelsKey = Key('radioContactChannels');

  const RadioContactChannels({
    required this.mainContactIdentifiers,
    super.key,
  });

  final String? mainContactIdentifiers;

  @override
  Widget build(BuildContext context) => mainContactIdentifiers != null
      ? Text(key: radioContactChannelsKey, mainContactIdentifiers!, style: DASTextStyles.xLargeRoman)
      : SizedBox.shrink();
}

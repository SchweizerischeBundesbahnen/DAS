import 'package:app/widgets/assets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModificationIcon extends StatelessWidget {
  static const Key iconKey = Key('modificationIcon');

  const ModificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconModificationIndicator,
      key: iconKey,
    );
  }
}

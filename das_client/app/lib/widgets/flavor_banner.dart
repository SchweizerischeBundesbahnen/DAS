import 'package:app/flavor.dart';
import 'package:material_ui/material_ui.dart';

class FlavorBanner extends StatelessWidget {
  const FlavorBanner({
    required this.flavor,
    required this.child,
    super.key,
  });

  final Flavor flavor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!flavor.showBanner) {
      return child;
    }
    return Directionality(
      textDirection: .ltr,
      child: Banner(
        color: flavor.color,
        message: flavor.displayName.toUpperCase(),
        location: BannerLocation.topStart,
        child: child,
      ),
    );
  }
}

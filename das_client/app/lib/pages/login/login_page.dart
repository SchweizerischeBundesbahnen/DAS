import 'package:app/pages/login/draggable_bottom_sheet.dart';
import 'package:app/widgets/assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';

final _log = Logger('LoginPage');

@RoutePage()
class LoginPage extends StatelessWidget {
  static const routeName = 'login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: .bottomCenter,
        children: [
          _background(),
          LoginDraggableBottomSheet(),
        ],
      ),
    );
  }

  Widget _background() => SvgPicture.asset(
    AppAssets.loginPageBackground,
    fit: .fill,
    width: double.infinity,
    height: double.infinity,
  );
}

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/flavor.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _log = Logger('LoginPage');

@RoutePage()
class LoginPage extends StatefulWidget {
  static const routeName = 'login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isTmsChecked = false;

  @override
  void initState() {
    DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: .bottomCenter,
        children: [
          _background(),
          _bottomSheet(context, child: isLoading ? _loading() : _body()),
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

  Widget _bottomSheet(BuildContext context, {required Widget child}) {
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(sbbDefaultSpacing),
            topRight: Radius.circular(sbbDefaultSpacing),
          ),
        ),
        shadows: [
          BoxShadow(
            color: SBBColors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
        color: ThemeUtil.getColor(context, SBBColors.white, SBBColors.charcoal),
      ),
      child: child,
    );
  }

  Widget _loading() {
    return Container(
      alignment: .center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.fromLTRB(56, 24, 32, 32),
      child: Row(
        children: [
          Expanded(child: _message(context)),
          // TODO: think of a way to display this information
          // _tmsCheckbox(context),
          // _flavor(context),
          _loginButton(context),
        ],
      ),
    );
  }

  Widget _message(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 8.0,
      children: [
        Text(context.l10n.p_login_bottom_sheet_title, style: sbbTextStyle.boldStyle.xLarge),
        Text(context.l10n.p_login_bottom_sheet_subtitle),
      ],
    );
  }

  Widget _flavor(BuildContext context) {
    final flavor = DI.get<Flavor>();
    return Container(
      alignment: .center,
      padding: const .all(16.0),
      child: Text(
        'Flavor: ${flavor.displayName}',
      ),
    );
  }

  Widget _tmsCheckbox(BuildContext context) {
    final flavor = DI.get<Flavor>();
    if (!flavor.isTmsEnabledForFlavor) return SizedBox.shrink();

    return Padding(
      padding: const .all(sbbDefaultSpacing),
      child: Row(
        mainAxisSize: .min,
        children: [
          SBBCheckbox(
            value: isTmsChecked,
            onChanged: (value) {
              setState(() {
                isTmsChecked = value ?? false;
                DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
              });
            },
          ),
          Text(context.l10n.p_login_connect_to_tms),
        ],
      ),
    );
  }

  Widget _loginButton(BuildContext context) {
    // TODO: change to SBBSecondaryButton with custom label once v5.0.0 is released
    // TODO: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
    return OutlinedButton(
      onPressed: _onLoginPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(context.l10n.p_login_login_button_text),
      ),
    );
  }

  void _onLoginPressed() async {
    final authenticator = DI.get<Authenticator>();

    setState(() {
      isLoading = true;
    });

    final context = this.context;
    try {
      await authenticator.login();
      await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      await DI.get<ScopeHandler>().push<JourneyScope>();
      if (context.mounted) {
        context.router.replace(const JourneySelectionRoute());
      }
    } catch (e) {
      _log.severe('Login failed', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.p_login_login_failed),
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}

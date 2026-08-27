import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_expiration_guard.dart';
import 'package:app/nav/app_link_navigator.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/nav/auth_guard.dart';
import 'package:app/theme/theme_view_model.dart';
import 'package:app/util/app_lifecycle_view_model.dart';
import 'package:app/widgets/flavor_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _appRouter = AppRouter(
    authGuard: AuthGuard(authenticator: DI.get()),
    appExpirationGuard: AppExpirationGuard(),
  );
  late AppLinkNavigator _appLinkNavigator;

  @override
  void initState() {
    super.initState();
    _appLinkNavigator = AppLinkNavigator(appLinksManager: DI.get(), router: _appRouter)..observe();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    DI.get<AppLifecycleViewModel>().updateState(state);
  }

  @override
  void dispose() {
    _appLinkNavigator.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ThemeViewModel(),
      dispose: (context, vm) => vm.dispose(),
      builder: (context, _) => FlavorBanner(
        flavor: DI.get(),
        child: _materialApp(context),
      ),
    );
  }

  Widget _materialApp(BuildContext context) {
    WakelockPlus.disable();
    return StreamBuilder(
      initialData: ThemeViewModel.defaultMode,
      stream: context.read<ThemeViewModel>().themeMode,
      builder: (context, snapshot) {
        final themeMode = snapshot.requireData;
        return MaterialApp.router(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: .noScaling),
              child: child!,
            );
          },
          themeMode: themeMode,
          theme: SBBTheme.light(themeContext: .safety, baseStyle: CandyBaseStyle.light()),
          darkTheme: SBBTheme.dark(themeContext: .safety, baseStyle: CandyBaseStyle.dark()),
          localizationsDelegates: localizationDelegates,
          supportedLocales: supportedLocales,
          localeResolutionCallback: defaultLocale,
          routerConfig: _appRouter.config(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// CANDY BASE STYLE

class CandyBaseStyle {
  CandyBaseStyle._();

  static SBBBaseStyle light() =>
      SBBBaseStyle.fromColorScheme(brightness: Brightness.light, colorScheme: _lightColorScheme);

  static SBBBaseStyle dark() =>
      SBBBaseStyle.fromColorScheme(brightness: Brightness.dark, colorScheme: _darkColorScheme);

  static final SBBColorScheme _lightColorScheme = SBBColorScheme(
    primary: SBBColors.pink,
    primary85: SBBColors.pinkDark,
    primary125: SBBColors.violet,
    primary150: SBBColors.violetDark,
    brand: SBBColors.turquoise,
    backgroundBase: const Color(0xFFFFF6E8),
    backgroundContent: SBBColors.white,
    error: SBBColors.error,
    iconPrimary: SBBColors.violet,
    iconSecondary: SBBColors.turquoise,
    textPrimary: SBBColors.black,
    textSecondary: SBBColors.turquoise,
    strokePrimary: SBBColors.pink,
    strokeSecondary: SBBColors.orange,
    strokeSeparator: SBBColors.peach,
    selection: SBBColors.lemon,
  );

  static final SBBColorScheme _darkColorScheme = SBBColorScheme(
    primary: SBBColors.pinkDark,
    primary85: SBBColors.violetDark,
    primary125: SBBColors.turquoiseDark,
    primary150: SBBColors.orangeDark,
    brand: SBBColors.lemonDark,
    backgroundBase: const Color(0xFF1A0B2E),
    backgroundContent: const Color(0xFF2B1245),
    error: SBBColors.errorDark,
    iconPrimary: SBBColors.lemonDark,
    iconSecondary: SBBColors.turquoiseDark,
    textPrimary: SBBColors.white,
    textSecondary: SBBColors.peachDark,
    strokePrimary: SBBColors.pinkDark,
    strokeSecondary: SBBColors.violetDark,
    strokeSeparator: SBBColors.orangeDark,
    selection: SBBColors.lemonDark,
  );
}

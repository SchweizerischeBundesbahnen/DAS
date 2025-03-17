import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/theme/theme_provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:das_client/app/widgets/flavor_banner.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sbbBaseStyle = SBBBaseStyle(
      primaryColor: SBBColors.royal,
      primaryColorDark: SBBColors.royal125,
      brightness: Brightness.light,
    );

    return FlavorBanner(
      flavor: DI.get(),
      child: ThemeManager(
          themeMode: _themeMode,
          toggleTheme: _toggleTheme,
          child: Builder(builder: (context) {
            final themeMode = ThemeManager.of(context)!.themeMode;
            return MaterialApp.router(
              themeMode: themeMode,
              theme: SBBTheme.light(
          baseStyle: sbbBaseStyle,
          controlStyles: SBBControlStyles(
            promotionBox: PromotionBoxStyle.$default(baseStyle: sbbBaseStyle).copyWith(
              badgeColor: SBBColors.royal,
              badgeShadowColor: SBBColors.royal.withAlpha((255.0 * 0.2).round()),
            ),
          ),
        ),
              darkTheme: SBBTheme.dark(
                baseStyle: sbbBaseStyle,
              ),
              localizationsDelegates: localizationDelegates,
              supportedLocales: supportedLocales,
              routerConfig: _appRouter.config(),
              debugShowCheckedModeBanner: false,
            );
          })),
    );
  }
}

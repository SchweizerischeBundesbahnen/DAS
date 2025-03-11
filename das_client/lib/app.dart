import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/theme/theme_provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:das_client/app/widgets/flavor_banner.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class App extends StatefulWidget {
  App({super.key});

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
    return ThemeManager(
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: Builder(
        builder: (context) {
          final themeMode = ThemeManager.of(context)!.themeMode;
          return MaterialApp.router(
            themeMode: themeMode,
            theme: SBBTheme.light(
              baseStyle: SBBBaseStyle(
                primaryColor: SBBColors.royal,
                primaryColorDark: SBBColors.royal125,
              ),
            ),
            darkTheme: SBBTheme.dark(
              baseStyle: SBBBaseStyle(
                primaryColor: SBBColors.royal,
                primaryColorDark: SBBColors.royal125,
              ),
            ),
            localizationsDelegates: localizationDelegates,
            supportedLocales: supportedLocales,
            routerConfig: _appRouter.config(),
    );
  }
}
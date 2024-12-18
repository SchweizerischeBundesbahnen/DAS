import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: SBBTheme.light(
        baseStyle: SBBBaseStyle(
          primaryColor: SBBColors.royal,
          primaryColorDark: SBBColors.royal125,
        ),
      ),
      //darkTheme: SBBTheme.dark(),
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      routerConfig: _appRouter.config(),
    );
  }
}

import 'package:das_client/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
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

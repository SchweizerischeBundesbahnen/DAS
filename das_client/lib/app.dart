import 'package:das_client/i18n/i18n.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  App({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      localizationsDelegates: localizationDelegates,
      supportedLocales: supportedLocales,
      routerConfig: _appRouter.config(),
    );
  }
}

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/theme/theme_view_model.dart';
import 'package:app/theme/themes.dart';
import 'package:app/widgets/flavor_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ThemeViewModel(),
      dispose: (context, vm) => vm.dispose(),
      builder: (context, __) => FlavorBanner(
        flavor: DI.get(),
        child: _materialApp(context),
      ),
    );
  }

  Widget _materialApp(BuildContext context) {
    return StreamBuilder(
      initialData: ThemeViewModel.defaultMode,
      stream: context.read<ThemeViewModel>().themeMode,
      builder: (context, snapshot) {
        final themeMode = snapshot.requireData;
        return MaterialApp.router(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
          themeMode: themeMode,
          theme: DASTheme.light(),
          darkTheme: DASTheme.dark(),
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

import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/app/widgets/flavor_banner.dart';
import 'package:das_client/di.dart';
import 'package:das_client/theme/theme_provider.dart';
import 'package:das_client/util/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(context),
      child: FlavorBanner(
        flavor: DI.get(),
        child: Builder(
          builder: (context) {
            final themeManager = context.watch<ThemeProvider>();

            return MaterialApp.router(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: child!,
                );
              },
              themeMode: themeManager.themeMode,
              theme: SBBTheme.light(
                baseStyle: SBBBaseStyle(
                  primarySwatch: SBBColors.royal.toSingleMaterialColor(),
                  primaryColor: SBBColors.royal,
                  primaryColorDark: SBBColors.royal125,
                  brightness: Brightness.light,
                ),
                controlStyles: SBBControlStyles(
                  promotionBox: PromotionBoxStyle.$default(
                    baseStyle: SBBBaseStyle(
                      primaryColor: SBBColors.royal,
                      primaryColorDark: SBBColors.royal125,
                      brightness: Brightness.light,
                    ),
                  ).copyWith(
                    badgeColor: SBBColors.royal,
                    badgeShadowColor: SBBColors.royal.withAlpha((255.0 * 0.2).round()),
                  ),
                ),
              ),
              darkTheme: SBBTheme.dark(
                baseStyle: SBBBaseStyle(
                  primarySwatch: SBBColors.royal.toSingleMaterialColor(),
                  primaryColor: SBBColors.royal,
                  primaryColorDark: SBBColors.royal125,
                  brightness: Brightness.dark,
                ),
                controlStyles: SBBControlStyles(
                  promotionBox: PromotionBoxStyle.$default(
                    baseStyle: SBBBaseStyle(
                      primaryColor: SBBColors.royal,
                      primaryColorDark: SBBColors.royal125,
                      brightness: Brightness.dark,
                    ),
                  ).copyWith(
                    badgeColor: SBBColors.royal,
                    badgeShadowColor: SBBColors.royal.withAlpha((255.0 * 0.2).round()),
                  ),
                ),
              ),
              localizationsDelegates: localizationDelegates,
              supportedLocales: supportedLocales,
              routerConfig: _appRouter.config(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}

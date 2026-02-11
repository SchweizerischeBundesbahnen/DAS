import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/preload/view_model/preload_view_model.dart';
import 'package:app/pages/preload/widgets/preload_status_display.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class PreloadPage extends StatelessWidget implements AutoRouteWrapper {
  const PreloadPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiProvider(
    providers: [
      Provider<PreloadViewModel>(create: (_) => PreloadViewModel(preloadRepository: DI.get())),
    ],
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeader _appBar(BuildContext context) {
    return SBBHeader(
      title: context.l10n.p_preload_page_title,
      systemOverlayStyle: .light,
      actions: [Container()],
    );
  }

  Widget _body(BuildContext context) {
    return SBBHeaderbox.custom(child: PreloadStatusDisplay());
  }
}

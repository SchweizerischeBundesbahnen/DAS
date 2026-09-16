import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/support/view_model/preload_view_model.dart';
import 'package:app/pages/support/widgets/preload_status_display.dart';
import 'package:app/pages/support/widgets/ru_feature_status_display.dart';
import 'package:app/pages/support/widgets/settings_status_display.dart';
import 'package:app/pages/support/widgets/support_url_display.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/app_version_text.dart';
import 'package:app/widgets/device_id_text.dart';
import 'package:app/widgets/user_header_box_preferred_size.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class SupportPage extends StatelessWidget implements AutoRouteWrapper {
  const SupportPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => Provider<PreloadViewModel>(
    create: (_) => PreloadViewModel(preloadRepository: DI.get()),
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

  SBBHeaderSmall _appBar(BuildContext context) {
    return SBBHeaderSmall(
      titleText: context.l10n.w_navigation_drawer_support_title,
      actions: const [], // removes SBB logo
      bottom: UserHeaderBoxPreferredSize(textScaler: MediaQuery.textScalerOf(context)),
    );
  }

  Widget _body(BuildContext context) {
    final textColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(SBBSpacing.small),
        child: Column(
          spacing: SBBSpacing.medium,
          children: [
            const SupportUrlDisplay(),
            const PreloadStatusDisplay(),
            Row(
              spacing: SBBSpacing.medium,
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Flexible(child: const RuFeatureStatusDisplay()),
                Flexible(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const SettingsStatusDisplay(),
                      SizedBox(height: SBBSpacing.xLarge),
                      AppVersionText(color: textColor),
                      DeviceIdText(color: textColor),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

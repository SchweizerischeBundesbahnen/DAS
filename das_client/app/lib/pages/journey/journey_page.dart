import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/journey_table/journey_overview.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/pages/journey/settings/journey_settings.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

@RoutePage()
class JourneyPage extends StatefulWidget implements AutoRouteWrapper {
  static const disconnectButtonKey = Key('disconnectButton');

  const JourneyPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiProvider(
    providers: [
      Provider<JourneyTableViewModel>(create: (_) => DI.get()),
      Provider<WarnAppViewModel>(create: (_) => DI.get()),
    ],
    child: this,
  );

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  StreamSubscription? _errorCodeSubscription;

  @override
  void initState() {
    final journeyTableVM = DI.get<JourneyTableViewModel>();
    _errorCodeSubscription = journeyTableVM.errorCode.listen((error) async {
      if (error != null) {
        await DI.get<ScopeHandler>().pop<JourneyScope>();
        await DI.get<ScopeHandler>().push<JourneyScope>();
        if (mounted) {
          context.router.replace(JourneySelectionRoute());
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _errorCodeSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list([
        context.read<JourneyTableViewModel>().settings,
        DI.get<JourneyNavigationViewModel>().model,
      ]),
      builder: (context, snapshot) {
        final settings = snapshot.data?[0] as JourneySettings?;
        final model = snapshot.data?[1] as JourneyNavigationModel?;

        return DASJourneyScaffold(
          body: JourneyOverview(),
          appBarTitle: _appBarTitle(context, model?.trainIdentification),
          hideAppBar: settings?.isAutoAdvancementEnabled == true,
          appBarTrailingAction: _DismissJourneyButton(),
        );
      },
    );
  }

  String _appBarTitle(BuildContext context, TrainIdentification? trainIdentification) {
    if (trainIdentification == null) {
      return context.l10n.c_app_name;
    }

    final locale = Localizations.localeOf(context);
    final date = Format.dateWithAbbreviatedDay(trainIdentification.date, locale);
    return '${context.l10n.p_journey_appbar_text} - $date';
  }
}

class _DismissJourneyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    key: JourneyPage.disconnectButtonKey,
    icon: const Icon(SBBIcons.train_small),
    onPressed: () async {
      DASTableRowBuilder.clearRowKeys();

      await DI.get<ScopeHandler>().pop<JourneyScope>();
      await DI.get<ScopeHandler>().push<JourneyScope>();
      if (context.mounted) {
        context.router.replace(JourneySelectionRoute());
      }
    },
  );
}

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/navigation/journey_navigation_model.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/table/das_table_row.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

@RoutePage()
class JourneyPage extends StatelessWidget implements AutoRouteWrapper {
  static const disconnectButtonKey = Key('disconnectButton');

  const JourneyPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => Provider<TrainJourneyViewModel>(
    create: (_) => DI.get(),
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list([
        context.read<TrainJourneyViewModel>().settings,
        DI.get<JourneyNavigationViewModel>().model,
      ]),
      builder: (context, snapshot) {
        final settings = snapshot.data?[0] as TrainJourneySettings?;
        final model = snapshot.data?[1] as JourneyNavigationModel?;

        return DASJourneyScaffold(
          body: _Content(),
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
    return '${context.l10n.p_train_journey_appbar_text} - $date';
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.list([
        viewModel.journey,
        viewModel.errorCode,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final journey = snapshot.data?[0] as Journey?;
        final errorCode = snapshot.data?[1] as ErrorCode?;

        if (errorCode != null) {
          return Center(
            child: SBBMessage(
              illustration: MessageIllustration.Display,
              title: context.l10n.c_something_went_wrong,
              description: errorCode.displayText(context),
              messageCode: '${context.l10n.c_error_code}: ${errorCode.code.toString()}',
            ),
          );
        } else if (journey != null) {
          return const TrainJourneyOverview();
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
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

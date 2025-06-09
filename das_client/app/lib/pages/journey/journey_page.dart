import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/pages/journey/train_selection/train_selection.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/format.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

@RoutePage()
class JourneyPage extends StatelessWidget {
  static const disconnectButtonKey = Key('disconnectButton');

  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<TrainJourneyViewModel>();
    return Provider(
      create: (_) => DI.get<TrainJourneyViewModel>(),
      child: StreamBuilder(
        stream: CombineLatestStream.list([viewModel.journey, viewModel.trainIdentification, viewModel.settings]),
        builder: (context, snapshot) {
          final journey = snapshot.data?[0] as Journey?;
          final trainIdentification = snapshot.data?[1] as TrainIdentification?;
          final settings = snapshot.data?[2] as TrainJourneySettings?;

          final showAppBar = journey == null || settings?.isAutoAdvancementEnabled == false;

          return DASJourneyScaffold(
            body: _body(context),
            appBarTitle: _headerTitle(context, trainIdentification),
            showAppBar: showAppBar,
            appBarTrailingAction: journey != null ? _trainSelectionButton(context) : _logoutButton(context),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _content(context)),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final viewModel = DI.get<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.list([
        viewModel.journey,
        viewModel.trainIdentification,
        viewModel.errorCode,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final journey = snapshot.data?[0] as Journey?;
        final trainIdentification = snapshot.data?[1] as TrainIdentification?;
        final errorCode = snapshot.data?[2] as ErrorCode?;

        if (trainIdentification == null || errorCode != null) {
          return const TrainSelection();
        } else if (journey != null) {
          return const TrainJourneyOverview();
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _logoutButton(BuildContext context) {
    return IconButton(
      icon: const Icon(SBBIcons.exit_small),
      onPressed: () {
        DI.get<Authenticator>().logout();
        context.router.replace(const LoginRoute());
      },
    );
  }

  Widget _trainSelectionButton(BuildContext context) {
    return IconButton(
      key: disconnectButtonKey,
      icon: const Icon(SBBIcons.train_small),
      onPressed: () => context.read<TrainJourneyViewModel>().reset(),
    );
  }

  String _headerTitle(BuildContext context, TrainIdentification? trainIdentification) {
    if (trainIdentification == null) {
      return context.l10n.c_app_name;
    }

    final locale = Localizations.localeOf(context);
    final date = Format.dateWithAbbreviatedDay(trainIdentification.date, locale);
    return '${context.l10n.p_train_journey_appbar_text} - $date';
  }
}

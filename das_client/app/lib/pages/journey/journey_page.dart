import 'package:app/di/di.dart';
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
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:sfera/component.dart';

@RoutePage()
class JourneyPage extends StatelessWidget implements AutoRouteWrapper {
  static const disconnectButtonKey = Key('disconnectButton');

  const JourneyPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => Provider<TrainJourneyViewModel>(
    create: (_) => TrainJourneyViewModel(sferaRemoteRepo: DI.get(), warnappRepo: DI.get()),
    dispose: (_, vm) => vm.dispose(),
    child: this,
  );
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> with SingleTickerProviderStateMixin {
  static const _toolbarHideAnimationDuration = 400;

  late final AnimationController _controller;
  late final Animation<double> _animation;
  double _toolbarHeight = kToolbarHeight;

  @override
  void initState() {
    super.initState();
    WakelockPlus.disable();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _toolbarHideAnimationDuration),
    );
    _animation = Tween<double>(begin: kToolbarHeight, end: 0.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _toolbarHeight = _animation.value;
        });
      });
  }

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
    onPressed: () {
      DI.get<JourneyNavigationViewModel>().reset();
      context.read<TrainJourneyViewModel>().reset();
      context.router.replace(JourneySelectionRoute());
    },
  );
}

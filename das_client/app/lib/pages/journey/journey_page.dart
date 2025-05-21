import 'package:app/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/pages/journey/train_selection/train_selection.dart';
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
class JourneyPage extends StatefulWidget {
  static const disconnectButtonKey = Key('disconnectButton');

  const JourneyPage({super.key});

  @override
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder<TrainJourneySettings>(
      stream: viewModel.settings,
      builder: (context, snapshot) {
        return Scaffold(
          //Handling overflow issues in train selection when tablet is too small
          resizeToAvoidBottomInset: screenHeight <= 830 ? true : null,
          appBar: _appBar(context, snapshot.data),
          body: _body(context),
          drawer: const DASNavigationDrawer(),
        );
      },
    );
  }

  PreferredSizeWidget? _appBar(BuildContext context, TrainJourneySettings? settings) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return PreferredSize(
      preferredSize: Size.fromHeight(_toolbarHeight),
      child: StreamBuilder(
        stream: CombineLatestStream.list([viewModel.journey, viewModel.trainIdentification]),
        builder: (context, snapshot) {
          final journey = snapshot.data?[0] as Journey?;
          final trainIdentification = snapshot.data?[1] as TrainIdentification?;

          final appBarHidden = journey != null && settings?.isAutoAdvancementEnabled == true;
          appBarHidden ? _controller.forward() : _controller.reverse();

          return SBBHeader(
            title: _headerTitle(context, trainIdentification),
            actions: [
              journey == null ? _logoutButton(context) : _trainSelectionButton(context),
            ],
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
    final viewModel = context.read<TrainJourneyViewModel>();
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
      key: JourneyPage.disconnectButtonKey,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

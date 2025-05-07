import 'package:app/bloc/auth_cubit.dart';
import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/pages/journey/train_selection/train_selection.dart';
import 'package:app/util/format.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class JourneyPage extends StatelessWidget {
  const JourneyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: DI.get<TrainJourneyCubit>(),
      child: JourneyPageContent(),
    );
  }
}

class JourneyPageContent extends StatefulWidget {
  const JourneyPageContent({super.key});

  static const disconnectKey = Key('disconnectButton');

  @override
  State<JourneyPageContent> createState() => _JourneyPageContentState();
}

class _JourneyPageContentState extends State<JourneyPageContent> with SingleTickerProviderStateMixin {
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
    return BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
      builder: (context, state) {
        return StreamBuilder<TrainJourneySettings>(
            stream: context.trainJourneyCubit.settingsStream,
            builder: (context, snapshot) {
              return Scaffold(
                //Handling overflow issues in train selection when tablet is too small
                resizeToAvoidBottomInset: screenHeight <= 830 ? true : null,
                appBar: _appBar(context, state, snapshot.data),
                body: _body(context, state),
                drawer: const DASNavigationDrawer(),
              );
            });
      },
    );
  }

  PreferredSizeWidget? _appBar(BuildContext context, TrainJourneyState state, TrainJourneySettings? settings) {
    final appBarHidden = state is TrainJourneyLoadedState && settings?.isAutoAdvancementEnabled == true;
    appBarHidden ? _controller.forward() : _controller.reverse();

    return PreferredSize(
      preferredSize: Size.fromHeight(_toolbarHeight),
      child: SBBHeader(
        title: _headerTitle(context, state),
        actions: [
          if (state is SelectingTrainJourneyState) _logoutButton(context),
          if (state is! SelectingTrainJourneyState) _trainSelectionButton(context)
        ],
      ),
    );
  }

  Widget _body(BuildContext context, TrainJourneyState state) {
    return Column(
      children: [
        Expanded(child: _content(state)),
      ],
    );
  }

  Widget _content(TrainJourneyState state) => switch (state) {
        SelectingTrainJourneyState() => const TrainSelection(),
        TrainJourneyLoadedState() => const TrainJourneyOverview(),
        _ => const Center(child: CircularProgressIndicator()),
      };

  IconButton _logoutButton(BuildContext context) {
    return IconButton(
      icon: const Icon(SBBIcons.exit_small),
      onPressed: () {
        context.authCubit.logout();
        context.router.replace(const LoginRoute());
      },
    );
  }

  IconButton _trainSelectionButton(BuildContext context) {
    return IconButton(
      key: JourneyPageContent.disconnectKey,
      icon: const Icon(SBBIcons.train_small),
      onPressed: () => context.trainJourneyCubit.reset(),
    );
  }

  String _headerTitle(BuildContext context, TrainJourneyState state) {
    if (state is TrainJourneyLoadedState) {
      final locale = Localizations.localeOf(context);
      final date = Format.dateWithAbbreviatedDay(state.trainIdentification.date, locale);
      return '${context.l10n.p_train_journey_appbar_text} - $date';
    }
    return context.l10n.c_app_name;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

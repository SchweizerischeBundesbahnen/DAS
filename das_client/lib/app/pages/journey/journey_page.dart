import 'package:auto_route/auto_route.dart';
import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/model/ru.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/app/nav/das_navigation_drawer.dart';
import 'package:das_client/app/pages/journey/train_journey/train_journey_overview.dart';
import 'package:das_client/app/pages/journey/train_selection/train_selection.dart';
import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/di.dart';
import 'package:das_client/util/format.dart';
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

class JourneyPageContent extends StatelessWidget {
  const JourneyPageContent({super.key});

  static const disconnectKey = Key('disconnectButton');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
        builder: (context, state) {
          return SBBHeader(
            title: _headerTitle(context, state),
            actions: [
              if (state is SelectingTrainJourneyState) _logoutButton(context),
              if (state is! SelectingTrainJourneyState) _trainSelectionButton(context)
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _content()),
      ],
    );
  }

  Widget _content() {
    return BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
      builder: (context, state) {
        if (state is SelectingTrainJourneyState) {
          return const TrainSelection();
        } else if (state is TrainJourneyLoadedState) {
          return const TrainJourneyOverview();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

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
      key: disconnectKey,
      icon: const Icon(SBBIcons.train_small),
      onPressed: () => context.trainJourneyCubit.reset(),
    );
  }

  String _headerTitle(BuildContext context, TrainJourneyState state) {
    if (state is TrainJourneyLoadedState) {
      final trainNumber = '${context.l10n.c_train_number} ${state.trainNumber}';
      final ru = state.ru.displayText(context);
      final date = Format.dateWithAbbreviatedDay(state.date);
      return '$trainNumber - $ru - $date';
    }
    return context.l10n.c_app_name;
  }
}

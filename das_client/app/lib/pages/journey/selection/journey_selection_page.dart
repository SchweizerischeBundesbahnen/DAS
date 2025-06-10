import 'dart:async';

import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/di/di.dart';
import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/navigation/journey_navigation_view_model.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/header.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

@RoutePage()
class JourneySelectionPage extends StatelessWidget implements AutoRouteWrapper {
  const JourneySelectionPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<JourneySelectionViewModel>(
      create: (_) => JourneySelectionViewModel(
        sferaRemoteRepo: DI.get<SferaRemoteRepo>(),
        onJourneySelected: DI.get<JourneyNavigationViewModel>().push,
      ),
      dispose: (context, vm) => vm.dispose(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DASJourneyScaffold(
      body: _Content(),
      appBarTitle: context.l10n.c_app_name,
      appBarTrailingAction: _LogoutButton(),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content();

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  late StreamSubscription<JourneySelectionModel?> _subscription;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<JourneySelectionViewModel>();
    _subscription = viewModel.model.listen((model) {
      if (model is Loaded) {
        Fimber.d('Loaded!');
        context.router.replace(JourneyRoute());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      BrightnessModalSheet.openIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                _Header(),
                Expanded(child: _Body()),
                _LoadJourneyButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _LoadJourneyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SBBLoadingIndicator();

        return switch (model) {
          final Loading _ || final Loaded _ || Error _ => SizedBox.shrink(),
          final Selecting sM => Padding(
            padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
            child: SBBPrimaryButton(
              label: context.l10n.c_button_confirm,
              onPressed: sM.isInputComplete ? () => viewModel.loadTrainJourney() : null,
            ),
          ),
        };
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SizedBox.shrink();

        return Header(
          information: !model.isStartDateSameAsToday ? context.l10n.p_train_selection_date_not_today_warning : null,
          child: Column(
            children: [
              JourneyTrainNumberInput(),
              JourneyDateInput(),
              JourneyRailwayUndertakingInput(),
            ],
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: context.read<JourneySelectionViewModel>().model,
    builder: (context, snapshot) {
      final model = snapshot.data;
      if (model == null) return SBBLoadingIndicator();

      return switch (model) {
        final Selecting _ || final Loaded _ => SizedBox.shrink(),
        final Loading _ => Center(child: CircularProgressIndicator()),
        final Error eM => SBBMessage(
          illustration: MessageIllustration.Display,
          title: context.l10n.c_something_went_wrong,
          description: eM.errorCode.displayText(context),
          messageCode: '${context.l10n.c_error_code}: ${eM.errorCode.code.toString()}',
        ),
      };
    },
  );
}

class JourneyRailwayUndertakingInput extends StatelessWidget {
  const JourneyRailwayUndertakingInput({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SizedBox.shrink();

        final currentRu = model.railwayUndertaking;

        return switch (model) {
          final Selecting _ || final Error _ => _buildRailwayUndertakingInput(
            context,
            currentRu,
            onChanged: (value) => viewModel.updateRailwayUndertaking(value),
          ),
          _ => _buildRailwayUndertakingInput(context, currentRu),
        };
      },
    );
  }

  _buildRailwayUndertakingInput(BuildContext context, value, {Function(RailwayUndertaking)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing),
      child: SBBSelect<RailwayUndertaking>(
        label: context.l10n.p_train_selection_ru_description,
        value: value,
        items: RailwayUndertaking.values
            .map((ru) => SelectMenuItem<RailwayUndertaking>(value: ru, label: ru.displayText(context)))
            .toList(),
        onChanged: onChanged != null ? (value) => value != null ? onChanged(value) : null : null,
        isLastElement: true,
      ),
    );
  }
}

class JourneyTrainNumberInput extends StatefulWidget {
  const JourneyTrainNumberInput({super.key});

  @override
  State<JourneyTrainNumberInput> createState() => _JourneyTrainNumberInputState();
}

class _JourneyTrainNumberInputState extends State<JourneyTrainNumberInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SizedBox.shrink();
        _controller.text = model.operationalTrainNumber;

        return switch (model) {
          final Selecting _ || final Error _ => _buildTrainNumberInput(
            context,
            onChanged: (value) => viewModel.updateTrainNumber(value),
            onSubmitted: (_) => viewModel.loadTrainJourney(),
          ),
          _ => _buildTrainNumberInput(context),
        };
      },
    );
  }

  Widget _buildTrainNumberInput(BuildContext context, {Function(String)? onChanged, Function(String)? onSubmitted}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, 0, sbbDefaultSpacing / 2),
      child: SBBTextField(
        enabled: onChanged != null,
        onChanged: onChanged,
        controller: _controller,
        labelText: context.l10n.p_train_selection_trainnumber_description,
        keyboardType: TextInputType.text,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(SBBIcons.exit_small),
    onPressed: () {
      DI.get<Authenticator>().logout();
      context.router.replace(const LoginRoute());
    },
  );
}

class JourneyDateInput extends StatefulWidget {
  const JourneyDateInput({super.key});

  @override
  State<JourneyDateInput> createState() => _JourneyDateInputState();
}

class _JourneyDateInputState extends State<JourneyDateInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SizedBox.shrink();

        final date = model.startDate;
        _controller.text = Format.date(date);

        return switch (model) {
          final Selecting _ || final Error _ => _dateInput(context, onTap: _showDatePicker(context, date)),
          _ => _dateInput(context),
        };
      },
    );
  }

  Widget _dateInput(BuildContext context, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2),
      child: GestureDetector(
        onTap: onTap,
        child: SBBTextField(
          labelText: context.l10n.p_train_selection_date_description,
          controller: _controller,
          enabled: false,
        ),
      ),
    );
  }

  VoidCallback _showDatePicker(BuildContext context, DateTime selectedDate) =>
      () => showSBBModalSheet(
        context: context,
        title: context.l10n.p_train_selection_choose_date,
        child: _datePickerWidget(context, selectedDate),
      );

  Widget _datePickerWidget(BuildContext context, DateTime selectedDate) {
    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SBBDatePicker(
          initialDate: selectedDate,
          minimumDate: now.add(Duration(days: -1)),
          maximumDate: now.add(Duration(hours: 4)),
          onDateChanged: (value) => context.read<JourneySelectionViewModel>().updateDate(value),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

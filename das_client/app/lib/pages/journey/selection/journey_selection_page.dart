import 'dart:async';

import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/pages/journey/selection/widgets/logout_button.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/util/error_code.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class JourneySelectionPage extends StatelessWidget implements AutoRouteWrapper {
  const JourneySelectionPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<JourneySelectionViewModel>(
      create: (_) => DI.get<JourneySelectionViewModel>(),
      dispose: (_, _) {}, // dispose is called when JourneyScope is popped
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DASJourneyScaffold(
      body: _Content(),
      appBarTitle: context.l10n.c_app_name,
      appBarTrailingAction: LogoutButton(),
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
      if (model is Loaded && mounted) {
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
                _header(context),
                Expanded(child: _body(context)),
                _loadJourneyButton(context),
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

  Widget _header(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        return SBBHeaderbox.custom(
          padding: EdgeInsets.zero,
          flap: !model.isStartDateSameAsToday
              ? SBBHeaderboxFlap(
                  title: context.l10n.p_train_selection_date_not_today_warning,
                  leadingIcon: SBBIcons.circle_information_small,
                )
              : null,
          child: Column(
            children: [
              JourneyDateInput(),
              SelectRailwayUndertakingInput(),
              JourneyTrainNumberInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        return switch (model) {
          final Selecting _ || final Loaded _ => SizedBox.shrink(),
          final Loading _ => Center(child: CircularProgressIndicator()),
          final Error e => SBBMessage(
            illustration: MessageIllustration.Display,
            title: context.l10n.c_something_went_wrong,
            description: e.errorCode.displayText(context),
            messageCode: '${context.l10n.c_error_code}: ${e.errorCode.code.toString()}',
          ),
        };
      },
    );
  }

  Widget _loadJourneyButton(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;

        Widget wrapWithPadding(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing * 0.5),
          child: child,
        );

        final buttonLabel = context.l10n.c_button_confirm;
        return switch (model) {
          final Loading _ => wrapWithPadding(SBBPrimaryButton(label: buttonLabel, onPressed: null, isLoading: true)),
          final Selecting s => Padding(
            padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
            child: SBBPrimaryButton(
              label: buttonLabel,
              onPressed: s.isInputComplete ? () => viewModel.loadJourney() : null,
            ),
          ),
          _ => wrapWithPadding(SBBPrimaryButton(label: buttonLabel, onPressed: null)),
        };
      },
    );
  }
}

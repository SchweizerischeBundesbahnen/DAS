import 'dart:async';

import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/app_expiration_dialog.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/pages/journey/selection/widgets/logout_button.dart';
import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:app/pages/journey/widgets/das_journey_scaffold.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class JourneySelectionPage extends StatelessWidget implements AutoRouteWrapper {
  const JourneySelectionPage({super.key, this._onAppExpiredDialogDismissed});

  final VoidCallback? _onAppExpiredDialogDismissed;

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppExpirationViewModel>.value(value: DI.get<AppExpirationViewModel>()),
        Provider<JourneySelectionViewModel>.value(value: DI.get<JourneySelectionViewModel>()),
      ],
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DASJourneyScaffold(
      body: _Content(onAppExpiredDialogDismissed: _onAppExpiredDialogDismissed),
      appBarTitle: context.l10n.c_app_name,
      appBarTrailingAction: LogoutButton(),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({this.onAppExpiredDialogDismissed});

  final VoidCallback? onAppExpiredDialogDismissed;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> with WidgetsBindingObserver {
  late StreamSubscription<JourneySelectionModel?> _subscription;
  late StreamSubscription<AppExpirationModel> _appExpirationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final viewModel = context.read<JourneySelectionViewModel>();
    _subscription = viewModel.model.listen((model) {
      if (model is Loaded && mounted) {
        context.router.replace(JourneyRoute());
      }
    });

    final appExpirationVM = context.read<AppExpirationViewModel>();
    appExpirationVM.checkIsAppExpired();

    _appExpirationSubscription = appExpirationVM.model.listen((model) {
      if (!mounted) return;
      if (model is Expired) {
        showAppExpiredDialog(model, context);
      } else if (model is ExpirySoon) {
        if (!model.userDismissedDialog) {
          showAppExpiresSoonDialog(model, context).then((_) {
            if (!mounted) return;
            appExpirationVM.dialogDismissedByUser();
            widget.onAppExpiredDialogDismissed?.call();
          });
        }
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
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    _appExpirationSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        context.read<JourneySelectionViewModel>().refreshDatesIfDayChanged();
      }
    }
  }

  Widget _header(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

        return SBBHeaderBox(
          padding: .zero,
          flap: !model.isStartDateSameAsToday
              ? SBBHeaderBoxFlap(
                  labelText: context.l10n.p_train_selection_date_not_today_warning,
                  leadingIconData: SBBIcons.circle_information_small,
                )
              : null,
          body: Column(
            children: [
              JourneyDateInput(),
              JourneyTrainNumberInput(),
              SelectRailwayUndertakingInput(
                selectedRailwayUndertakings: [?model.railwayUndertaking],
                updateRailwayUndertaking: viewModel.updateRailwayUndertaking,
              ),
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
          final Loading _ || final LoadingCompanyMatches _ => Center(child: CircularProgressIndicator()),
          final SelectingCompanyMatch s => _companyMatchesSelectionBody(context, s),
          final Error e => SBBMessage(
            illustration: SBBIllustration.display(),
            titleText: context.l10n.c_something_went_wrong,
            subtitleText: e.errorCode.displayText(context),
            errorText: '${context.l10n.c_error_code}: ${e.errorCode.code.toString()}',
          ),
        };
      },
    );
  }

  Widget _companyMatchesSelectionBody(BuildContext context, SelectingCompanyMatch model) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: SBBSpacing.xSmall, vertical: SBBSpacing.medium),
      child: SingleChildScrollView(
        child: Column(
          spacing: SBBSpacing.xSmall,
          children: [
            _companyMatchesTitle(context),
            if (model.companyMatches.isNotEmpty) _companyMatchesList(context, model),
          ],
        ),
      ),
    );
  }

  Widget _companyMatchesTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SBBSpacing.medium),
      child: Column(
        spacing: SBBSpacing.medium,
        children: [
          Text(context.l10n.p_train_selection_no_match_title, style: SBBTextStyles.mediumLight),
          Text(context.l10n.p_train_selection_no_match_subtitle, style: SBBTextStyles.smallLight),
        ],
      ),
    );
  }

  Widget _companyMatchesList(BuildContext context, SelectingCompanyMatch model) {
    final companyMatches = model.companyMatches.sorted((a, b) => a.startDate.compareTo(b.startDate));

    return Column(
      crossAxisAlignment: .start,
      spacing: SBBSpacing.xSmall,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.medium),
          child: Text(context.l10n.p_train_selection_company_matches_title, style: SBBTextStyles.smallLight),
        ),
        SBBRadioGroup(
          groupValue: model.selectedCompanyMatch,
          onChanged: (value) {
            final viewModel = context.read<JourneySelectionViewModel>();
            viewModel.updateSelectedCompanyMatch(value);
          },
          child: SBBContentBox(
            child: Column(
              children: List.generate(
                companyMatches.length,
                (index) => _companyMatchesListItem(context, model, companyMatches[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyMatchesListItem(BuildContext context, SelectingCompanyMatch model, CompanyMatch companyMatch) {
    final isDateBold = DateUtils.isSameDay(model.startDate, companyMatch.startDate);
    final subtitleColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);

    return SBBRadioListItem(
      value: companyMatch,
      title: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            '${companyMatch.ru.companyCode}, ${companyMatch.ru.name.toUpperCase()}',
            style: SBBTextStyles.mediumLight,
          ),
          Text(
            Format.date(companyMatch.startDate),
            style: isDateBold
                ? SBBTextStyles.smallBold.copyWith(color: subtitleColor)
                : SBBTextStyles.smallLight.copyWith(color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _loadJourneyButton(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.data;

        Widget wrapWithPadding(Widget child) => Padding(
          padding: const .symmetric(vertical: SBBSpacing.medium, horizontal: SBBSpacing.xSmall),
          child: child,
        );

        final buttonLabel = context.l10n.c_button_confirm;
        return switch (model) {
          final Loading _ || final LoadingCompanyMatches _ => wrapWithPadding(
            SBBPrimaryButton(labelText: buttonLabel, onPressed: null, isLoading: true),
          ),
          final Selecting _ || final SelectingCompanyMatch _ => Padding(
            padding: const .symmetric(vertical: SBBSpacing.medium, horizontal: SBBSpacing.xSmall),
            child: SBBPrimaryButton(
              labelText: buttonLabel,
              onPressed: model!.isInputComplete ? () => viewModel.loadJourney() : null,
            ),
          ),
          _ => wrapWithPadding(SBBPrimaryButton(labelText: buttonLabel, onPressed: null)),
        };
      },
    );
  }
}

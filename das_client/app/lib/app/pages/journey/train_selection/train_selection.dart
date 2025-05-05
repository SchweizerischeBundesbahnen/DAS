import 'package:app/app/bloc/train_journey_cubit.dart';
import 'package:app/app/extension/ru_extension.dart';
import 'package:app/app/i18n/i18n.dart';
import 'package:app/app/widgets/header.dart';
import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:sfera/src/model/ru.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TrainSelection extends StatefulWidget {
  const TrainSelection({super.key});

  @override
  State<TrainSelection> createState() => _TrainSelectionState();
}

class _TrainSelectionState extends State<TrainSelection> {
  late TextEditingController _trainNumberController;
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _trainNumberController = TextEditingController();
    _dateController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BrightnessModalSheet.openIfNeeded(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
      builder: (context, state) {
        if (state is SelectingTrainJourneyState) {
          return _body(context, state);
        } else {
          return Container();
        }
      },
    );
  }

  Widget _body(BuildContext context, SelectingTrainJourneyState state) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _header(context, state),
                    _errorMessage(context, state),
                    Spacer(),
                    _loadButton(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, SelectingTrainJourneyState state) {
    return Header(
      information: !DateUtils.isSameDay(state.date, DateTime.now())
          ? context.l10n.p_train_selection_date_not_today_warning
          : null,
      child: Column(
        children: [
          _trainNumberInput(state),
          _dateInput(state),
          _ruSelection(context, state),
        ],
      ),
    );
  }

  Widget _trainNumberInput(SelectingTrainJourneyState state) {
    if (state.errorCode != null && state.trainNumber != null) {
      _trainNumberController.text = state.trainNumber!;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, 0, sbbDefaultSpacing / 2),
      child: SBBTextField(
        onChanged: (value) => context.trainJourneyCubit.updateTrainNumber(value),
        controller: _trainNumberController,
        labelText: context.l10n.p_train_selection_trainnumber_description,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _dateInput(SelectingTrainJourneyState state) {
    _dateController.text = Format.date(state.date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2),
      child: GestureDetector(
        onTap: () => _showDatePicker(context, state),
        child: SBBTextField(
          labelText: context.l10n.p_train_selection_date_description,
          controller: _dateController,
          enabled: false,
        ),
      ),
    );
  }

  Widget _ruSelection(BuildContext context, SelectingTrainJourneyState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing),
      child: SBBSelect<Ru>(
        label: context.l10n.p_train_selection_ru_description,
        value: state.ru,
        items: Ru.values.map((ru) => SelectMenuItem<Ru>(value: ru, label: ru.displayText(context))).toList(),
        onChanged: (selectedRu) => context.trainJourneyCubit.updateCompany(selectedRu),
        isLastElement: true,
      ),
    );
  }

  Widget _errorMessage(BuildContext context, SelectingTrainJourneyState state) {
    if (state.errorCode != null) {
      return SBBMessage(
        illustration: MessageIllustration.Display,
        title: context.l10n.c_something_went_wrong,
        description: state.errorCode!.displayText(context),
        messageCode: '${context.l10n.c_error_code}: ${state.errorCode!.code.toString()}',
      );
    }
    return Container();
  }

  Widget _loadButton(BuildContext context, SelectingTrainJourneyState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
      child: SBBPrimaryButton(
        label: context.l10n.c_button_confirm,
        onPressed: _canContinue(state) ? () => context.trainJourneyCubit.loadTrainJourney() : null,
      ),
    );
  }

  void _showDatePicker(BuildContext context, SelectingTrainJourneyState state) {
    showSBBModalSheet(
        context: context, title: context.l10n.p_train_selection_choose_date, child: _datePickerWidget(context, state));
  }

  Widget _datePickerWidget(BuildContext context, SelectingTrainJourneyState state) {
    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SBBDatePicker(
          initialDate: state.date,
          minimumDate: now.add(Duration(days: -1)),
          maximumDate: now.add(Duration(hours: 4)),
          onDateChanged: (value) => context.trainJourneyCubit.updateDate(value),
        ),
      ],
    );
  }

  bool _canContinue(SelectingTrainJourneyState state) {
    return state.trainNumber != null && state.trainNumber!.isNotEmpty && state.ru != null;
  }
}

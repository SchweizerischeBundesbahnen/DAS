import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/model/ru.dart';
import 'package:das_client/app/widgets/header.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    _trainNumberController = TextEditingController(text: 'T9999');
    _dateController = TextEditingController();

    context.trainJourneyCubit.updateTrainNumber(_trainNumberController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainJourneyCubit, TrainJourneyState>(
      builder: (context, state) {
        if (state is SelectingTrainJourneyState) {
          return Column(
            children: [
              Header(child: _headerWidgets(context, state)),
              Spacer(),
              _errorWidget(context, state),
              Spacer(),
              _loadButton(context, state)
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _headerWidgets(BuildContext context, SelectingTrainJourneyState state) {
    return Column(
      children: [
        _trainNumberWidget(),
        _dateDisplayWidget(state),
        _ruSelectionWidget(context, state),
      ],
    );
  }

  Widget _trainNumberWidget() {
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

  Widget _dateDisplayWidget(SelectingTrainJourneyState state) {
    if (DateUtils.isSameDay(state.date, DateTime.now())) {
      _dateController.text = Format.date(state.date);
    } else {
      _dateController.text = '${Format.date(state.date)} ${context.l10n.p_train_selection_date_not_today_warning}';
    }

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

  Widget _ruSelectionWidget(BuildContext context, SelectingTrainJourneyState state) {
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

  Widget _errorWidget(BuildContext context, SelectingTrainJourneyState state) {
    if (state.errorCode != null) {
      return Text(state.errorCode!.displayTextWithErrorCode(context), style: SBBTextStyles.mediumBold);
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

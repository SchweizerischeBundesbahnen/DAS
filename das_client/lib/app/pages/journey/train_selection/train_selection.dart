import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/model/ru.dart';
import 'package:das_client/app/widgets/header.dart';
import 'package:das_client/util/error_code.dart';
import 'package:das_client/util/format.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
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
    _trainNumberController = TextEditingController(text: '7839');
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
        _evuSelectionWidget(context, state),
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
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _dateDisplayWidget(SelectingTrainJourneyState state) {
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

  Widget _evuSelectionWidget(BuildContext context, SelectingTrainJourneyState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing),
      child: SBBSelect<Ru>(
        label: context.l10n.p_train_selection_evu_description,
        value: state.evu,
        items: Ru.values.map((vTyp) => SelectMenuItem<Ru>(value: vTyp, label: vTyp.displayText(context))).toList(),
        onChanged: (selectedEvu) => context.trainJourneyCubit.updateCompany(selectedEvu),
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
        label: context.l10n.p_train_selection_load,
        onPressed: _canContinue(state)
            ? () {
                final trainJourneyCubit = context.trainJourneyCubit;
                if (!trainJourneyCubit.isClosed) {
                  trainJourneyCubit.loadTrainJourney();
                }
              }
            : null,
      ),
    );
  }

  void _showDatePicker(BuildContext context, SelectingTrainJourneyState state) {
    showSBBModalSheet(
        context: context, title: context.l10n.p_train_selection_choose_date, child: _datePickerWidget(context, state));
  }

  Widget _datePickerWidget(BuildContext context, SelectingTrainJourneyState state) {
    DateTime now = DateTime.now();
    now.add(Duration(days: -1));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SBBDatePicker(
            initialDate: state.date,
            minimumDate: now.add(Duration(days: -1)),
            maximumDate: now.add(Duration(hours: 4)),
            onDateChanged: (value) => context.trainJourneyCubit.updateDate(value)),
      ],
    );
  }

  bool _canContinue(SelectingTrainJourneyState state) {
    return state.trainNumber != null && state.trainNumber!.isNotEmpty && state.evu != null;
  }
}

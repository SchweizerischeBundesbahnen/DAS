import 'package:app/bloc/train_journey_view_model.dart';
import 'package:app/brightness/brightness_modal_sheet.dart';
import 'package:app/extension/ru_extension.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/util/error_code.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

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
                    _header(context),
                    _errorMessage(context),
                    Spacer(),
                    _confirmButton(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
        stream: viewModel.selectedDate,
        builder: (context, snapshot) {
          final selectedDate = snapshot.data;
          return Header(
            information: !DateUtils.isSameDay(selectedDate, DateTime.now())
                ? context.l10n.p_train_selection_date_not_today_warning
                : null,
            child: Column(
              children: [
                _trainNumberInput(context),
                _dateInput(selectedDate),
                _ruSelection(context),
              ],
            ),
          );
        });
  }

  Widget _trainNumberInput(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
        stream: viewModel.selectedTrainNumber,
        builder: (context, snapshot) {
          _trainNumberController.text = snapshot.data ?? '';
          return Padding(
            padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, 0, sbbDefaultSpacing / 2),
            child: SBBTextField(
              onChanged: (value) => viewModel.updateTrainNumber(value),
              controller: _trainNumberController,
              labelText: context.l10n.p_train_selection_trainnumber_description,
              keyboardType: TextInputType.text,
            ),
          );
        });
  }

  Widget _dateInput(DateTime? selectedDate) {
    _dateController.text = selectedDate != null ? Format.date(selectedDate) : '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2),
      child: GestureDetector(
        onTap: () => selectedDate != null ? _showDatePicker(context, selectedDate) : null,
        child: SBBTextField(
          labelText: context.l10n.p_train_selection_date_description,
          controller: _dateController,
          enabled: false,
        ),
      ),
    );
  }

  Widget _ruSelection(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: viewModel.selectedRailwayUndertaking,
      builder: (context, snapshot) {
        final railwayUndertaking = snapshot.data;
        return Padding(
          padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing),
          child: SBBSelect<RailwayUndertaking>(
            label: context.l10n.p_train_selection_ru_description,
            value: railwayUndertaking,
            items: RailwayUndertaking.values
                .map((ru) => SelectMenuItem<RailwayUndertaking>(value: ru, label: ru.displayText(context)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateRailwayUndertaking(value);
              }
            },
            isLastElement: true,
          ),
        );
      },
    );
  }

  Widget _errorMessage(BuildContext context) {
    final viewModel = context.read<TrainJourneyViewModel>();
    return StreamBuilder(
      stream: viewModel.errorCode,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox.shrink();

        final errorCode = snapshot.requireData;
        return SBBMessage(
          illustration: MessageIllustration.Display,
          title: context.l10n.c_something_went_wrong,
          description: errorCode!.displayText(context),
          messageCode: '${context.l10n.c_error_code}: ${errorCode.code.toString()}',
        );
      },
    );
  }

  Widget _confirmButton(BuildContext context) {
    return StreamBuilder(
      stream: context.read<TrainJourneyViewModel>().formCompleted,
      builder: (context, snapshot) {
        final formCompleted = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
          child: SBBPrimaryButton(
            label: context.l10n.c_button_confirm,
            onPressed: formCompleted ? () => context.read<TrainJourneyViewModel>().loadTrainJourney() : null,
          ),
        );
      },
    );
  }

  void _showDatePicker(BuildContext context, DateTime selectedDate) {
    showSBBModalSheet(
        context: context,
        title: context.l10n.p_train_selection_choose_date,
        child: _datePickerWidget(context, selectedDate));
  }

  Widget _datePickerWidget(BuildContext context, DateTime selectedDate) {
    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SBBDatePicker(
          initialDate: selectedDate,
          minimumDate: now.add(Duration(days: -1)),
          maximumDate: now.add(Duration(hours: 4)),
          onDateChanged: (value) => context.read<TrainJourneyViewModel>().updateDate(value),
        ),
      ],
    );
  }
}

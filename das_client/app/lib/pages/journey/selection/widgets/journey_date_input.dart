import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

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
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final model = snapshot.requireData;

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

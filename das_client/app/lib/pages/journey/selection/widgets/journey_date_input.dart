import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_picker.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _inputPadding = EdgeInsets.fromLTRB(sbbDefaultSpacing, 0, 0, sbbDefaultSpacing / 2);

class JourneyDateInput extends StatefulWidget {
  const JourneyDateInput({
    super.key,
    this.isModalVersion = false,
  });

  final bool isModalVersion;

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
      padding: widget.isModalVersion ? EdgeInsets.zero : _inputPadding,
      child: GestureDetector(
        onTap: onTap,
        child: SBBTextField(
          labelText: widget.isModalVersion ? null : context.l10n.p_train_selection_date_description,
          hintText: widget.isModalVersion ? context.l10n.p_train_selection_date_description : null,
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
        child: Provider.value(
          value: context.read<JourneySelectionViewModel>(),
          builder: (_, _) => JourneyDatePicker(selectedDate: selectedDate),
        ),
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

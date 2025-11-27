import 'package:app/i18n/i18n.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

const _inputPadding = EdgeInsets.fromLTRB(sbbDefaultSpacing, sbbDefaultSpacing, 0, sbbDefaultSpacing / 2);

class JourneyDateTextField extends StatefulWidget {
  const JourneyDateTextField({required this.onTap, required this.isModalVersion, required this.date, super.key});

  final VoidCallback onTap;
  final bool isModalVersion;
  final DateTime date;

  @override
  State<JourneyDateTextField> createState() => _JourneyDateTextFieldState();
}

class _JourneyDateTextFieldState extends State<JourneyDateTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController(text: Format.date(widget.date));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant JourneyDateTextField oldWidget) {
    if (oldWidget.date != widget.date) {
      _textController.text = Format.date(widget.date);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: Padding(
      padding: widget.isModalVersion ? .zero : _inputPadding,
      child: SBBTextField(
        labelText: widget.isModalVersion ? null : context.l10n.p_train_selection_date_description,
        hintText: widget.isModalVersion ? context.l10n.p_train_selection_date_description : null,
        controller: _textController,
        enabled: false,
      ),
    ),
  );
}

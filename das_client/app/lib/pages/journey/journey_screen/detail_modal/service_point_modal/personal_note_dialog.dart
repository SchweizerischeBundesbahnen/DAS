import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:personal_notes/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class PersonalNoteDialog extends StatefulWidget {
  const PersonalNoteDialog({this.note, super.key});

  final PersonalNote? note;

  @override
  State<PersonalNoteDialog> createState() => _PersonalNoteDialogState();
}

class _PersonalNoteDialogState extends State<PersonalNoteDialog> {
  static const double _maxWidth = 430;

  late final TextEditingController expandableTextEditingController;

  @override
  void initState() {
    super.initState();
    expandableTextEditingController = TextEditingController.fromValue(
      TextEditingValue(text: widget.note?.text ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SBBPopup(
      style: SBBPopupStyle(
        constraints: BoxConstraints(maxWidth: _maxWidth),
      ),
      titleText: _editMode
          ? context.l10n.w_personal_note_dialog_edit_title
          : context.l10n.w_personal_note_dialog_create_title,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: SBBSpacing.xSmall,
      children: [
        SBBTextInputBoxed(
          decoration: SBBInputDecoration(
            labelText: context.l10n.w_personal_note_dialog_textfield_label,
          ),
          controller: expandableTextEditingController,
          minLines: 5,
          maxLines: null,
        ),
        SBBSwitchListItem(
          titleText: context.l10n.w_personal_note_dialog_footnote_checkbox_label,
          value: true,
          onChanged: (t) {},
        ),
        SBBSwitchListItem(
          titleText: context.l10n.w_personal_note_dialog_single_use_checkbox_label,
          value: true,
          onChanged: (t) {},
        ),
        SizedBox(height: SBBSpacing.xSmall),
        SBBSecondaryButton(
          label: SizedBox(
            width: double.maxFinite,
            child: Center(
              child: Text(context.l10n.w_personal_note_dialog_button_delete),
            ),
          ),
          onPressed: () {},
        ),
        SBBPrimaryButton(labelText: context.l10n.w_personal_note_dialog_button_save, onPressed: () {}),
      ],
    );
  }

  bool get _editMode => widget.note != null;
}

Future<PersonalNote?> showPersonalNoteDialog(BuildContext context, PersonalNote? note) => showDialog(
  context: context,
  builder: (context) => PersonalNoteDialog(note: note),
);

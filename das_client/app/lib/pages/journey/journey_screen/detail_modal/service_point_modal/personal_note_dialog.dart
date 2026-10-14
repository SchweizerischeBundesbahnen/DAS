import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_notes_view_model.dart';
import 'package:app/widgets/modal_sheet/das_modal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _log = Logger('PersonalNoteDialog');

class PersonalNoteDialog extends StatefulWidget {
  static const dialogKey = Key('personalNoteDialog');
  static const textAreaKey = Key('personalNoteDialogTextArea');
  static const saveButtonKey = Key('personalNoteDialogSaveButton');
  static const showAsFootNoteSwitchKey = Key('personalNoteDialogShowAsFootNoteSwitch');
  static const singleUseSwitchKey = Key('personalNoteDialogSingleUseSwitch');
  static const deleteButtonKey = Key('personalNoteDialogDeleteButton');

  const PersonalNoteDialog({
    required this.viewModel,
    this.modalSheetController,
    this.note,
    super.key,
  });

  final PersonalNotesViewModel viewModel;
  final DASModalSheetController? modalSheetController;
  final PersonalNote? note;

  @override
  State<PersonalNoteDialog> createState() => _PersonalNoteDialogState();
}

class _PersonalNoteDialogState extends State<PersonalNoteDialog> {
  static const double _maxWidth = 430;
  static const int _maxInputLength = 1000;

  late final TextEditingController textController;
  late bool _showAsFootnote;
  late bool _singleUse;
  String? _errorMessage;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    widget.modalSheetController?.stopAutomaticClose();

    _showAsFootnote = widget.note?.showAsFootnote ?? false;
    _singleUse = widget.note?.trainIdentification != null;
    textController = TextEditingController(text: widget.note?.text ?? '');
    textController.addListener(() {
      setState(() {
        if (textController.text.trim().length > _maxInputLength) {
          _validationError = context.l10n.w_personal_note_dialog_text_too_long(_maxInputLength);
        } else {
          _validationError = null;
        }
      });
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SBBPopup(
      key: PersonalNoteDialog.dialogKey,
      style: SBBPopupStyle(
        constraints: BoxConstraints(maxWidth: _maxWidth),
      ),
      titleText: _editMode
          ? context.l10n.w_personal_note_dialog_edit_title
          : context.l10n.w_personal_note_dialog_create_title,
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisSize: .min,
      children: [
        if (_errorMessage != null) ...[
          SBBNotificationBox.alert(contentText: _errorMessage!),
          SizedBox(height: SBBSpacing.small),
        ],
        _textArea(),
        SizedBox(height: SBBSpacing.xSmall),
        _showAsFootNoteCheckbox(),
        _singleUseCheckbox(),
        SizedBox(height: SBBSpacing.small),
        if (_editMode) ...[
          _deleteButton(),
          SizedBox(height: SBBSpacing.xSmall),
        ],
        _saveButton(),
      ],
    );
  }

  Widget _saveButton() => SBBPrimaryButton(
    key: PersonalNoteDialog.saveButtonKey,
    labelText: context.l10n.w_personal_note_dialog_button_save,
    onPressed: _inputIsValid ? () => _onSave() : null,
  );

  Widget _deleteButton() => SBBSecondaryButton(
    key: PersonalNoteDialog.deleteButtonKey,
    label: SizedBox(
      width: double.maxFinite,
      child: Center(
        child: Text(context.l10n.w_personal_note_dialog_button_delete),
      ),
    ),
    onPressed: () => _onDelete(),
  );

  Widget _singleUseCheckbox() => SBBSwitchListItem(
    key: PersonalNoteDialog.singleUseSwitchKey,
    titleText: context.l10n.w_personal_note_dialog_single_use_checkbox_label,
    value: _singleUse,
    onChanged: _editMode ? null : (value) => setState(() => _singleUse = value),
  );

  Widget _showAsFootNoteCheckbox() => SBBSwitchListItem(
    key: PersonalNoteDialog.showAsFootNoteSwitchKey,
    titleText: context.l10n.w_personal_note_dialog_footnote_checkbox_label,
    value: _showAsFootnote,
    onChanged: (value) => setState(() => _showAsFootnote = value),
  );

  Widget _textArea() => SBBTextInputBoxed(
    key: PersonalNoteDialog.textAreaKey,
    decoration: SBBInputDecoration(
      labelText: context.l10n.w_personal_note_dialog_textfield_label,
      errorText: _validationError,
    ),
    controller: textController,
    minLines: 5,
    maxLines: null,
  );

  bool get _inputIsValid => textController.text.trim().isNotEmpty && _validationError == null;

  Future<void> _onSave() async {
    try {
      await widget.viewModel.saveNote(
        text: textController.text.trim(),
        showAsFootnote: _showAsFootnote,
        singleUse: _singleUse,
      );

      _closeDialog();
    } catch (_) {
      _showErrorMessage();
    }
  }

  Future<void> _onDelete() async {
    if (widget.note == null) return;
    try {
      await widget.viewModel.deleteNote(widget.note!);
      _closeDialog();
    } catch (_) {
      _showErrorMessage();
    }
  }

  void _closeDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorMessage() {
    if (mounted) {
      setState(() => _errorMessage = context.l10n.w_personal_note_dialog_error_message);
    }
  }

  bool get _editMode => widget.note != null;
}

Future<PersonalNote?> showPersonalNoteDialog(
  BuildContext context,
  PersonalNotesViewModel viewModel,
  PersonalNote? note,
) => showDialog(
  context: context,
  builder: (_) => PersonalNoteDialog(viewModel: viewModel, note: note),
);

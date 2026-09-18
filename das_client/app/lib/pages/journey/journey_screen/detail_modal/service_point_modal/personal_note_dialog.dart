import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_notes_view_model.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

final _log = Logger('PersonalNoteDialog');

class PersonalNoteDialog extends StatefulWidget {
  const PersonalNoteDialog({
    required this.viewModel,
    super.key,
  });

  final PersonalNotesViewModel viewModel;

  @override
  State<PersonalNoteDialog> createState() => _PersonalNoteDialogState();
}

class _PersonalNoteDialogState extends State<PersonalNoteDialog> {
  static const double _maxWidth = 430;
  static const double _maxInputLength = 1000;

  late final TextEditingController textController;
  late bool _showAsFootnote;
  late bool _singleUse;
  String? _errorMessage;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _showAsFootnote = _currentNote?.showAsFootnote ?? false;
    _singleUse = _currentNote?.trainIdentification != null;
    textController = TextEditingController(text: _currentNote?.text ?? '');
    textController.addListener(() {
      setState(() {
        if (textController.text.trim().length > _maxInputLength) {
          _validationError = context.l10n.w_personal_note_dialog_text_too_long;
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
        SBBTextInputBoxed(
          decoration: SBBInputDecoration(
            labelText: context.l10n.w_personal_note_dialog_textfield_label,
            errorText: _validationError,
          ),
          controller: textController,
          minLines: 5,
          maxLines: null,
        ),
        SizedBox(height: SBBSpacing.xSmall),
        SBBSwitchListItem(
          titleText: context.l10n.w_personal_note_dialog_footnote_checkbox_label,
          value: _showAsFootnote,
          onChanged: (value) => setState(() => _showAsFootnote = value),
        ),
        SBBSwitchListItem(
          titleText: context.l10n.w_personal_note_dialog_single_use_checkbox_label,
          value: _singleUse,
          onChanged: (value) => setState(() => _singleUse = value),
        ),
        SizedBox(height: SBBSpacing.small),
        if (_editMode) ...[
          SBBSecondaryButton(
            label: SizedBox(
              width: double.maxFinite,
              child: Center(
                child: Text(context.l10n.w_personal_note_dialog_button_delete),
              ),
            ),
            onPressed: () => _onDelete(),
          ),
          SizedBox(height: SBBSpacing.xSmall),
        ],
        SBBPrimaryButton(
          labelText: context.l10n.w_personal_note_dialog_button_save,
          onPressed: _inputIsValid ? () => _onSave() : null,
        ),
      ],
    );
  }

  bool get _inputIsValid => textController.text.trim().isNotEmpty && _validationError == null;

  Future<void> _onSave() async {
    try {
      await widget.viewModel.saveNote(
        text: textController.text.trim(),
        showAsFootnote: _showAsFootnote,
        singleUse: _singleUse,
      );

      _closeDialog();
    } catch (e) {
      _log.severe('Error saving personal note', e);
      _showErrorMessage();
    }
  }

  Future<void> _onDelete() async {
    try {
      await widget.viewModel.deleteNote();

      _closeDialog();
    } catch (e) {
      _log.severe('Error deleting personal note', e);
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
      setState(() {
        _errorMessage = context.l10n.w_personal_note_dialog_error_message;
      });
    }
  }

  bool get _editMode => _currentNote != null;

  PersonalNote? get _currentNote => widget.viewModel.personalNoteValue;
}

Future<PersonalNote?> showPersonalNoteDialog(BuildContext context, PersonalNotesViewModel viewModel) => showDialog(
  context: context,
  builder: (_) => PersonalNoteDialog(viewModel: viewModel),
);

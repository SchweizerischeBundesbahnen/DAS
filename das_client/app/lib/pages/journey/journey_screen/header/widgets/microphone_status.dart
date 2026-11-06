import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/assets.dart';
import 'package:app/widgets/exclamation_icon_button.dart';
import 'package:app/widgets/microphone_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:voice_chat/component.dart';

class MicrophoneStatus extends StatelessWidget {
  static const Key iconKey = Key('microphoneStatus');

  const MicrophoneStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = DI.get<VoiceChatRepository>();
    if (!repository.isEnabled) return const SizedBox.shrink();

    return StreamBuilder<VoiceSession>(
      initialData: repository.current,
      stream: repository.session,
      builder: (context, snapshot) {
        final session = snapshot.requireData;
        final hasProblem = _isPermissionMissing(session) || session.error != null;
        final icon = hasProblem
            ? AppAssets.iconMicAlert
            : session.isMuted
            ? AppAssets.iconMicMuted
            : AppAssets.iconMicNormal;

        return Padding(
          padding: const .only(right: 20),
          child: hasProblem
              ? ExclamationIconButton(
                  icon: icon,
                  key: iconKey,
                  onTap: () {
                    unawaited(_openProblemSheet(context, session));
                  },
                )
              : MicrophoneIconButton(
                  icon: icon,
                  key: iconKey,
                  onTap: () {
                    unawaited(repository.setMuted(!session.isMuted));
                  },
                ),
        );
      },
    );
  }

  static bool _isPermissionMissing(VoiceSession session) =>
      session.permission == MicPermission.denied || session.permission == MicPermission.permanentlyDenied;

  Future<void> _openProblemSheet(BuildContext context, VoiceSession session) async {
    final texts = _problemTexts(context, session);
    await showSBBBottomSheet(
      context: context,
      style: const SBBBottomSheetStyle(
        constraints: BoxConstraints(minWidth: double.infinity),
      ),
      body: Center(
        heightFactor: 1,
        child: SBBMessage(
          titleText: texts.title,
          subtitleText: texts.text,
          illustration: SBBIllustration.display(),
        ),
      ),
    );
  }

  ({String title, String text}) _problemTexts(BuildContext context, VoiceSession session) {
    final l10n = context.l10n;
    if (_isPermissionMissing(session) || session.error == VoiceError.permissionDenied) {
      return (title: l10n.w_microphone_status_title, text: l10n.w_microphone_status_text);
    }
    return (
      title: l10n.w_microphone_status_error_title,
      text: switch (session.error) {
        VoiceError.serverUnreachable => l10n.w_microphone_status_error_server_unreachable,
        VoiceError.tokenInvalid => l10n.w_microphone_status_error_token_invalid,
        VoiceError.duplicateIdentity => l10n.w_microphone_status_error_duplicate_identity,
        _ => l10n.w_microphone_status_error_unknown,
      },
    );
  }
}

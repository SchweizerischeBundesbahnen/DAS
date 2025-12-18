import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

sealed class ErrorCode {
  const ErrorCode({required this.code});

  factory ErrorCode.fromSfera({required SferaError error}) = SferaErrorCode;

  final String code;
}

class SferaErrorCode extends ErrorCode {
  SferaErrorCode({required this.error}) : super(code: error.code);

  SferaError error;
}

extension ErrorCodeExtension on ErrorCode {
  String displayTextWithErrorCode(BuildContext context) {
    return '$code: ${displayText(context)}';
  }

  String displayText(BuildContext context) {
    return switch (this) {
      final SferaErrorCode se => se.displayText(context),
    };
  }
}

extension SferaErrorExtension on SferaError {
  String displayText(BuildContext context) {
    return switch (this) {
      // TODO: How to handle multiple errors in UI?
      final ProtocolErrors e => 'PROTOCOL ERROR ${e.errors}',
      ConnectionFailed() => context.l10n.c_error_connection_failed,
      ValidationFailed() => context.l10n.c_error_sfera_validation_failed,
      HandshakeRejected() => context.l10n.c_error_sfera_handshake_rejected,
      RequestTimeout() => context.l10n.c_error_sfera_request_timeout,
      JpUnavailable() => context.l10n.c_error_sfera_jp_unavailable,
      Invalid() => context.l10n.c_error_sfera_invalid,
    };
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

sealed class ErrorCode {
  const ErrorCode({required this.code});

  factory ErrorCode.fromSfera({required SferaError error}) = SferaErrorCode;

  final String code;

  String displayText(BuildContext context);
}

class SferaErrorCode extends ErrorCode {
  SferaErrorCode({required this.error}) : super(code: error.code);

  SferaError error;

  @override
  String displayText(BuildContext context) {
    return switch (error) {
      final ProtocolErrors e => e.errors.map((error) => error.displayText(context)).join('\n'),
      ConnectionFailed() => context.l10n.c_error_connection_failed,
      ValidationFailed() => context.l10n.c_error_sfera_validation_failed,
      HandshakeRejected() => context.l10n.c_error_sfera_handshake_rejected,
      RequestTimeout() => context.l10n.c_error_sfera_request_timeout,
      JpUnavailable() => context.l10n.c_error_sfera_jp_unavailable,
      Invalid() => context.l10n.c_error_sfera_invalid,
    };
  }
}

extension ProtocolErrorExtension on ProtocolError {
  String displayText(BuildContext context) {
    final codeText = '${context.l10n.c_error_code} $code';
    final errorText = additionalInfo?.localized ?? context.l10n.c_error_sfera_no_additional_info;
    return '$codeText: $errorText';
  }
}

import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

enum ErrorCode {
  connectionFailed(code: 1),
  sferaValidationFailed(code: 10000),
  sferaHandshakeRejected(code: 10001),
  sferaRequestTimeout(code: 10002),
  sferaJpUnavailable(code: 10003),
  sferaInvalid(code: 10004);

  const ErrorCode({
    required this.code,
  });

  factory ErrorCode.fromSfera(SferaError error) {
    switch (error) {
      case SferaError.connectionFailed:
        return ErrorCode.connectionFailed;
      case SferaError.validationFailed:
        return ErrorCode.sferaValidationFailed;
      case SferaError.handshakeRejected:
        return ErrorCode.sferaHandshakeRejected;
      case SferaError.requestTimeout:
        return ErrorCode.sferaRequestTimeout;
      case SferaError.jpUnavailable:
        return ErrorCode.sferaJpUnavailable;
      case SferaError.invalid:
        return ErrorCode.sferaInvalid;
    }
  }

  final int code;
}

extension ErrorCodeExtension on ErrorCode {
  String displayTextWithErrorCode(BuildContext context) {
    return '$code: ${displayText(context)}';
  }

  String displayText(BuildContext context) {
    switch (this) {
      case ErrorCode.connectionFailed:
        return context.l10n.c_error_connection_failed;
      case ErrorCode.sferaValidationFailed:
        return context.l10n.c_error_sfera_validation_failed;
      case ErrorCode.sferaHandshakeRejected:
        return context.l10n.c_error_sfera_handshake_rejected;
      case ErrorCode.sferaRequestTimeout:
        return context.l10n.c_error_sfera_request_timeout;
      case ErrorCode.sferaJpUnavailable:
        return context.l10n.c_error_sfera_jp_unavailable;
      case ErrorCode.sferaInvalid:
        return context.l10n.c_error_sfera_invalid;
    }
  }
}

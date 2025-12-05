import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

enum ErrorCode {
  connectionFailed(code: 1),
  sferaValidationFailed(code: 10000),
  sferaHandshakeRejected(code: 10001),
  sferaRequestTimeout(code: 10002),
  sferaJpUnavailable(code: 10003),
  sferaInvalid(code: 10004)
  ;

  const ErrorCode({
    required this.code,
  });

  factory ErrorCode.fromSfera(SferaError error) => switch (error) {
    .connectionFailed => .connectionFailed,
    .validationFailed => .sferaValidationFailed,
    .handshakeRejected => .sferaHandshakeRejected,
    .requestTimeout => .sferaRequestTimeout,
    .jpUnavailable => .sferaJpUnavailable,
    .invalid => .sferaInvalid,
  };

  final int code;
}

extension ErrorCodeExtension on ErrorCode {
  String displayTextWithErrorCode(BuildContext context) {
    return '$code: ${displayText(context)}';
  }

  String displayText(BuildContext context) {
    return switch (this) {
      .connectionFailed => context.l10n.c_error_connection_failed,
      .sferaValidationFailed => context.l10n.c_error_sfera_validation_failed,
      .sferaHandshakeRejected => context.l10n.c_error_sfera_handshake_rejected,
      .sferaRequestTimeout => context.l10n.c_error_sfera_request_timeout,
      .sferaJpUnavailable => context.l10n.c_error_sfera_jp_unavailable,
      .sferaInvalid => context.l10n.c_error_sfera_invalid,
    };
  }
}

import 'package:sfera/component.dart';

/// This class represents SFERA errors that can occur e.g. during connection, validation and returned by protocol itself [ProtocolErrors].
///
/// [code]: The SFERA protocol currently defines error codes between 2 - 55 (ex. 50 "Could not process data").
/// For custom error codes use the range from 1000 upwards.
sealed class SferaError {
  const SferaError._({required this.code});

  factory SferaError.protocolError({Iterable<ProtocolError> errors}) = ProtocolErrors;

  factory SferaError.connectionFailed() = ConnectionFailed;

  factory SferaError.validationFailed() = ValidationFailed;

  factory SferaError.handshakeRejected() = HandshakeRejected;

  factory SferaError.requestTimeout() = RequestTimeout;

  factory SferaError.jpUnavailable() = JpUnavailable;

  factory SferaError.invalid() = Invalid;

  final String code;
}

final class ProtocolErrors extends SferaError {
  const ProtocolErrors({this.errors = const []}) : super._(code: '0');

  final Iterable<ProtocolError> errors;
}

final class ProtocolError {
  const ProtocolError({required this.code, this.additionalInfo});

  final String code;
  final LocalizedString? additionalInfo;
}

final class Invalid extends SferaError {
  const Invalid() : super._(code: '1000');
}

final class ConnectionFailed extends SferaError {
  const ConnectionFailed() : super._(code: '1001');
}

final class ValidationFailed extends SferaError {
  const ValidationFailed() : super._(code: '1002');
}

final class HandshakeRejected extends SferaError {
  const HandshakeRejected() : super._(code: '1003');
}

final class RequestTimeout extends SferaError {
  const RequestTimeout() : super._(code: '1004');
}

final class JpUnavailable extends SferaError {
  const JpUnavailable() : super._(code: '1005');
}

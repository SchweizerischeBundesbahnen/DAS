import 'package:collection/collection.dart';
import 'package:core_data/component.dart';

/// This class represents SFERA errors that can occur e.g. during connection, validation and returned by protocol itself [ProtocolErrors].
///
/// [code]: The SFERA protocol currently defines error codes between 2 - 55 (ex. 50 "Could not process data").
/// For custom error codes use the range from 1000 upwards.
sealed class const SferaError._({required final String code}) {
  factory protocolError({Iterable<ProtocolError> errors}) = ProtocolErrors;

  factory connectionFailed() = ConnectionFailed;

  factory validationFailed() = ValidationFailed;

  factory handshakeRejected() = HandshakeRejected;

  factory requestTimeout() = RequestTimeout;

  factory jpUnavailable() = JpUnavailable;

  factory invalid() = Invalid;

  @override
  String toString() {
    return 'SferaError{code: $code}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SferaError && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

final class const ProtocolErrors({final Iterable<ProtocolError> errors = const []}) extends SferaError {
  this : super._(code: '0');

  @override
  String toString() {
    return 'ProtocolErrors{errors: $errors}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ProtocolErrors &&
          runtimeType == other.runtimeType &&
          super == other &&
          IterableEquality().equals(errors, other.errors);

  @override
  int get hashCode => Object.hash(super.hashCode, errors);
}

final class const ProtocolError({
  required final String code,
  final LocalizedString? additionalInfo,
}) {
  @override
  String toString() {
    return 'ProtocolError{code: $code, additionalInfo: $additionalInfo}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProtocolError &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          additionalInfo == other.additionalInfo;

  @override
  int get hashCode => Object.hash(code, additionalInfo);
}

final class const Invalid() extends SferaError {
  this : super._(code: '1000');
}

final class const ConnectionFailed() extends SferaError {
  this : super._(code: '1001');
}

final class const ValidationFailed() extends SferaError {
  this : super._(code: '1002');
}

final class const HandshakeRejected() extends SferaError {
  this : super._(code: '1003');
}

final class const RequestTimeout() extends SferaError {
  this : super._(code: '1004');
}

final class const JpUnavailable() extends SferaError {
  this : super._(code: '1005');
}

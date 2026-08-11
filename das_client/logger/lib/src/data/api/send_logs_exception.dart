/// Classifies failures of sending logs to the remote endpoint.
sealed class SendLogsException implements Exception {
  const SendLogsException(this.cause);

  /// The underlying failure, e.g. an HttpException or a connection error.
  final Object cause;

  @override
  String toString() => '$runtimeType{cause: $cause}';
}

/// The send failed for a reason that may resolve itself, e.g. missing connectivity,
/// server errors, throttling or a misconfigured token. Keep the payload and retry later.
class TransientSendLogsException extends SendLogsException {
  const TransientSendLogsException(super.cause);
}

/// The remote rejected the payload. Retrying can never succeed, discard the payload.
class PermanentSendLogsException extends SendLogsException {
  const PermanentSendLogsException(super.cause);
}

/// Classifies failures of sending logs to the remote endpoint.
sealed class const SendLogsException(this.cause) implements Exception {
  /// The underlying failure, e.g. an HttpException or a connection error.
  final Object cause;

  @override
  String toString() => '$runtimeType{cause: $cause}';
}

/// The send failed for a reason that may resolve itself, e.g. missing connectivity,
/// server errors, throttling or a misconfigured token. Keep the payload and retry later.
class const TransientSendLogsException(super.cause) extends SendLogsException;

/// The remote rejected the payload. Retrying can never succeed, discard the payload.
class const PermanentSendLogsException(super.cause) extends SendLogsException;

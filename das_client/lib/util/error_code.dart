
enum ErrorCode {
  connectionFailed(code: 1),

  sferaValidationFailed(code: 10000),
  sferaHandshakeRejected(code: 10001),
  sferaRequestTimeout(code: 10002);

  const ErrorCode({
    required this.code,
  });

  final int code;
}
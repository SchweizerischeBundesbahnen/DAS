import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/sfera_error.dart';
import 'package:sfera/src/data/dto/message_header_dto.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

typedef TaskFailed = void Function(SferaTask task, SferaError sferaError);
typedef TaskCompleted<T> = void Function(SferaTask task, T? data);

final _log = Logger('SferaTask');

abstract class SferaTask<T>({final Duration _timeout = defaultTimeout}) {
  static const defaultTimeout = Duration(seconds: 30);

  Timer? timeoutTimer;

  /// The ID of the request message used to compare to [MessageHeaderDto.correlationId].
  String? requestMessageId;

  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  /// executes given SFERA task. Use callback [TaskCompleted] and [TaskFailed] to handle result.
  Future<void> execute(TaskCompleted<T> onCompleted, TaskFailed onFailed);

  /// Passes message to [handleReplyMessage] if correlated to the latest request sent by this task.
  Future<bool> handleMessage(SferaG2bReplyMessageDto replyMessage) async {
    if (isCancelled || requestMessageId == null || replyMessage.messageHeader.correlationId != requestMessageId) {
      return false;
    }

    return handleReplyMessage(replyMessage);
  }

  /// Handles a reply whose correlation ID matches [requestMessageId].
  Future<bool> handleReplyMessage(SferaG2bReplyMessageDto replyMessage);

  void cancel() {
    _isCancelled = true;
    stopTimeout();
  }

  void startTimeout(TaskFailed onFailed) {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(_timeout, () {
      _log.severe('Timeout reached for task $this');
      onFailed(this, .requestTimeout());
    });
  }

  void stopTimeout() {
    timeoutTimer?.cancel();
    timeoutTimer = null;
  }

  @override
  String toString() => runtimeType.toString();
}

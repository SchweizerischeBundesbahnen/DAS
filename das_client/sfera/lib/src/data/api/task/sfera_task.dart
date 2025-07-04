import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sfera/src/data/api/sfera_error.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message_dto.dart';

typedef TaskFailed = void Function(SferaTask task, SferaError sferaError);
typedef TaskCompleted<T> = void Function(SferaTask task, T? data);

final _log = Logger('SferaTask');

abstract class SferaTask<T> {
  SferaTask({Duration? timeout}) : _timeout = timeout ?? const Duration(seconds: 15);

  final Duration _timeout;
  Timer? timeoutTimer;

  Future<void> execute(TaskCompleted<T> onCompleted, TaskFailed onFailed);

  Future<bool> handleMessage(SferaG2bReplyMessageDto replyMessage);

  void startTimeout(TaskFailed onFailed) {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(_timeout, () {
      _log.severe('Timeout reached for task $this');
      onFailed(this, SferaError.requestTimeout);
    });
  }

  void stopTimeout() {
    timeoutTimer?.cancel();
    timeoutTimer = null;
  }
}

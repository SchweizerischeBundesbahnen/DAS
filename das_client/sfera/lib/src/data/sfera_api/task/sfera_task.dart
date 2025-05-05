import 'dart:async';

import 'package:fimber/fimber.dart';
import 'package:sfera/src/data/dto/sfera_g2b_reply_message.dart';
import 'package:sfera/src/data/sfera_api/sfera_error.dart';

typedef TaskFailed = void Function(SferaTask task, SferaError sferaError);
typedef TaskCompleted<T> = void Function(SferaTask task, T? data);

abstract class SferaTask<T> {
  SferaTask({Duration? timeout}) : _timeout = timeout ?? const Duration(seconds: 15);

  final Duration _timeout;
  Timer? timeoutTimer;

  Future<void> execute(TaskCompleted<T> onCompleted, TaskFailed onFailed);

  Future<bool> handleMessage(SferaG2bReplyMessage replyMessage);

  void startTimeout(TaskFailed onFailed) {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(_timeout, () {
      Fimber.e('Timeout reached for task $this');
      onFailed(this, SferaError.requestTimeout);
    });
  }

  void stopTimeout() {
    timeoutTimer?.cancel();
    timeoutTimer = null;
  }
}

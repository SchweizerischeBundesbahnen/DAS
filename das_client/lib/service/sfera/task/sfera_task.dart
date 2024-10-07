import 'dart:async';

import 'package:das_client/service/sfera/handler/sfera_message_handler.dart';
import 'package:das_client/util/error_code.dart';
import 'package:fimber/fimber.dart';

typedef TaskFailed = void Function(SferaTask task, ErrorCode errorCode);
typedef TaskCompleted<T> = void Function(SferaTask task, T? data);

abstract class SferaTask<T> implements SferaMessageHandler {
  SferaTask({Duration? timeoutDuration}) : _timeoutDuration = timeoutDuration ?? const Duration(seconds: 10);

  final Duration _timeoutDuration;
  Timer? timeoutTimer;

  Future<void> execute(TaskCompleted<T> onCompleted, TaskFailed onFailed);

  void startTimeout(
    TaskFailed onFailed,
  ) {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(_timeoutDuration, () {
      Fimber.e("Timeout reached for task $this");
      onFailed(this, ErrorCode.sferaRequestTimeout);
    });
  }

  void stopTimeout() {
    timeoutTimer?.cancel();
    timeoutTimer = null;
  }
}

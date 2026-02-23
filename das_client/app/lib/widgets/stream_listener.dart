import 'dart:async';

import 'package:flutter/widgets.dart';

typedef StreamOnDataListener<T> = void Function(T data);

class StreamListener<T> extends StatefulWidget {
  const StreamListener({
    required this.stream,
    required this.onData,
    this.child,
    super.key,
  });

  final Stream<T> stream;
  final StreamOnDataListener<T> onData;
  final Widget? child;

  @override
  State<StreamListener> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {
  late StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(
      widget.onData,
    );
  }

  @override
  void didUpdateWidget(covariant StreamListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.stream != widget.stream || oldWidget.onData != widget.onData) {
      _subscription.cancel();
      _subscription = widget.stream.listen(widget.onData);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child ?? SizedBox.shrink();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';

typedef StreamOnDataListener<T> = void Function(T data);

class StreamListener<T> extends StatefulWidget {
  const StreamListener({
    required this.stream,
    required this.onData,
    super.key,
  });

  final Stream<T> stream;
  final StreamOnDataListener<T> onData;

  @override
  State<StreamListener> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {
  late final StreamSubscription<T> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(
      widget.onData,
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox.shrink();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

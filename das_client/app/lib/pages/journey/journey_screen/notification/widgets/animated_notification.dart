import 'package:app/util/animation.dart';
import 'package:flutter/widgets.dart';

/// Animates the show and hide (fade and size transition) of a notification driven by [stream].
class AnimatedNotification<T> extends StatelessWidget {
  const AnimatedNotification({
    required this.stream,
    required this.isVisible,
    required this.builder,
    this.initialData,
    super.key,
  });

  final Stream<T> stream;

  final T? initialData;

  final bool Function(T? data) isVisible;

  final Widget Function(BuildContext context, T? data) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final visible = isVisible(data);
        return AnimatedSwitcher(
          duration: DASAnimation.mediumDuration,
          switchInCurve: Curves.easeInOutCubicEmphasized,
          switchOutCurve: Curves.easeInOutCubicEmphasized,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, alignment: Alignment.topCenter, child: child),
          ),
          child: visible
              ? KeyedSubtree(key: const ValueKey('animatedNotificationVisible'), child: builder(context, data))
              : const SizedBox(key: ValueKey('animatedNotificationHidden'), width: double.infinity),
        );
      },
    );
  }
}

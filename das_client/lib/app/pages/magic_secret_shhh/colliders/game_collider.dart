import 'dart:ui';

class GameCollider {
  final Offset center;
  final double size;
  final double? height;

  const GameCollider({
    required this.center,
    required this.size,
    this.height,
  });

  Rect get rect => Rect.fromCenter(
        center: center,
        width: size,
        height: height ?? size,
      );

  bool collidesWith(GameCollider other) {
    return rect.overlaps(other.rect);
  }
}

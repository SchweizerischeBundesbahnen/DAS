import 'package:das_client/app/pages/magic_secret_shhh/models/barrier_model.dart';
import 'package:das_client/app/pages/magic_secret_shhh/colliders/game_collider.dart';
import 'package:flutter/material.dart';

class CollisionService {
  static bool checkCollision({
    required GameCollider bird,
    required List<BarrierModel> barriers,
    required Size screenSize,
  }) {
    for (final barrier in barriers) {
      final double x = barrier.x;
      final List<double> heights = barrier.heights;
      final double offset = barrier.offset;
      final double barrierWidth = 55;
      final double barrierXPos = (x + 1) / 2 * screenSize.width;

      final topCollider = GameCollider(
        center: Offset(barrierXPos + barrierWidth / 2, heights[0] / 2 + offset),
        size: barrierWidth,
        height: heights[0],
      );

      final bottomCollider = GameCollider(
        center: Offset(barrierXPos + barrierWidth / 2, screenSize.height - heights[1] / 2 + offset),
        size: barrierWidth,
        height: heights[1],
      );

      if (bird.collidesWith(topCollider) || bird.collidesWith(bottomCollider)) {
        return true;
      }
    }
    return false;
  }
}

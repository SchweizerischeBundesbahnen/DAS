import 'package:das_client/model/journey/velocity.dart';

class SpeedData {
  SpeedData({List<Velocity>? velocities}) : velocities = velocities ?? <Velocity>[];

  final List<Velocity> velocities;
}

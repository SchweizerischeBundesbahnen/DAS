import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class Journey {
  const Journey({required this.metadata, required this.data, this.valid = true});

  Journey.invalid({Metadata? metadata, List<BaseData>? data})
    : this(metadata: metadata ?? Metadata(), data: data ?? [], valid: false);

  final Metadata metadata;
  final List<BaseData> data;
  final bool valid;

  List<JourneyPoint> get journeyPoints => data.whereType<JourneyPoint>().toList();
}

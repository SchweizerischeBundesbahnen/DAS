import 'package:core_data/component.dart';
import 'package:meta/meta.dart';
import 'package:sfera/component.dart';

@sealed
@immutable
class const Journey({required final Metadata metadata, required final List<BaseData> data, final bool valid = true}) {
  Journey.invalid({Metadata? metadata, List<BaseData>? data})
    : this(metadata: metadata ?? Metadata(), data: data ?? [], valid: false);

  List<JourneyPoint> get journeyPoints => data.whereType<JourneyPoint>().toList();
}

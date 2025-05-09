import 'package:meta/meta.dart';
import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/metadata.dart';

@sealed
@immutable
class Journey {
  const Journey({required this.metadata, required this.data, this.valid = true});

  final Metadata metadata;
  final List<BaseData> data;
  final bool valid;

  Journey.invalid({Metadata? metadata, List<BaseData>? data})
      : this(metadata: metadata ?? Metadata(), data: data ?? [], valid: false);
}

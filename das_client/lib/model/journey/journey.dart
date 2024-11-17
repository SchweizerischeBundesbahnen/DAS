import 'package:das_client/model/journey/base_data.dart';
import 'package:das_client/model/journey/metadata.dart';

class Journey {
  const Journey({required this.metadata, required this.data, this.valid = true});

  final Metadata metadata;
  final List<BaseData> data;
  final bool valid;

  Journey.invalid({Metadata? metadata, List<BaseData>? data})
      : this(metadata: metadata ?? Metadata(), data: data ?? [], valid: false);
}

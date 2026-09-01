import 'package:core_data/component.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class const LocalRegulationSection({
  required final LocalizedString title,
  required final LocalizedString content,
}) {
  @override
  String toString() {
    return 'LocalRegulationSection{title: $title, content: $content}';
  }
}

import 'package:core_data/component.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class LocalRegulationSection {
  const LocalRegulationSection({
    required this.title,
    required this.content,
  });

  final LocalizedString title;
  final LocalizedString content;

  @override
  String toString() {
    return 'LocalRegulationSection{title: $title, content: $content}';
  }
}

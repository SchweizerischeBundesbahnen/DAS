import 'package:meta/meta.dart';
import 'package:sfera/src/model/localized_string.dart';

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

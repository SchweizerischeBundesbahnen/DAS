import 'package:meta/meta.dart';

@immutable
class const LocalRegulationSection({
  required final String id,
  required final String? title,
  required final String? content,
  final String? children,
}) {
  @override
  String toString() {
    return 'LocalRegulationSection{id: $id, title: $title, content: $content, children: $children}';
  }
}

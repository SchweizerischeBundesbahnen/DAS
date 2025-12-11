import 'package:collection/collection.dart';
import 'package:formation/component.dart';

class FormationRunChange {
  FormationRunChange({
    required this.formationRun,
    required this.previousFormationRun,
  }) {
    _calculateChanges();
  }

  final FormationRun formationRun;
  final FormationRun? previousFormationRun;
  final Map<String, bool> _changes = {};

  bool hasChanged(String propertyName) => _changes[propertyName] ?? false;

  void _calculateChanges() {
    if (previousFormationRun == null) return;

    final a = formationRun.toJson();
    final b = previousFormationRun!.toJson();

    for (final key in a.keys) {
      final va = a[key];
      final vb = b[key];

      if (va == vb) continue;

      if (va is List && vb is List) {
        if (!ListEquality().equals(va, vb)) _changes[key] = true;
      } else {
        _changes[key] = true;
      }
    }
  }
}

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

  bool hasChanged(FormationRunFields field) => _changes[field.fieldName] ?? false;

  int get changesCount => _changes.length;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormationRunChange &&
          runtimeType == other.runtimeType &&
          formationRun == other.formationRun &&
          previousFormationRun == other.previousFormationRun &&
          MapEquality().equals(_changes, other._changes);

  @override
  int get hashCode => Object.hash(formationRun, previousFormationRun, _changes);

  @override
  String toString() {
    return 'FormationRunChange{formationRun: $formationRun, previousFormationRun: $previousFormationRun, _changes: $_changes}';
  }
}

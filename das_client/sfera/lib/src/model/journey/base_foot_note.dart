import 'package:sfera/src/model/journey/base_data.dart';
import 'package:sfera/src/model/journey/foot_note.dart';

abstract class BaseFootNote extends BaseData {
  BaseFootNote({
    required super.order,
    required this.footNote,
    required super.type,
  }) : super(kilometre: []);

  final FootNote footNote;

  String get identifier => footNote.identifier ?? hashCode.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseFootNote && runtimeType == other.runtimeType && footNote == other.footNote && order == other.order;

  @override
  int get hashCode => footNote.hashCode ^ order.hashCode;
}

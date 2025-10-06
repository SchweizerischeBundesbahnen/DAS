import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('Test balise group without other points', () {
    final baliseGroup = BaliseGroup(
      balise: Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 1),
      levelCrossings: [
        LevelCrossing(order: 101, kilometre: [0.11]),
      ],
      otherPoints: [],
    );

    expect(baliseGroup.shownLevelCrossingsCount(), 1);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[0]), false);
  });

  test('Test balise group with multiple level crossings without other points', () {
    final baliseGroup = BaliseGroup(
      balise: Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 2),
      levelCrossings: [
        LevelCrossing(order: 101, kilometre: [0.11]),
        LevelCrossing(order: 102, kilometre: [0.12]),
      ],
      otherPoints: [],
    );

    expect(baliseGroup.shownLevelCrossingsCount(), 2);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[0]), false);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[1]), false);
  });

  test('Test balise group with multiple level crossings with service point between', () {
    final baliseGroup = BaliseGroup(
      balise: Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 2),
      levelCrossings: [
        LevelCrossing(order: 101, kilometre: [0.11]),
        LevelCrossing(order: 105, kilometre: [0.14]),
      ],
      otherPoints: [
        ServicePoint(name: 'Dummy', order: 103, kilometre: [0.12]),
      ],
    );

    expect(baliseGroup.shownLevelCrossingsCount(), 1);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[0]), false);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[1]), true);
  });

  test('Test balise group with multiple level crossings with none service point between', () {
    final baliseGroup = BaliseGroup(
      balise: Balise(order: 100, kilometre: [0.1], amountLevelCrossings: 2),
      levelCrossings: [
        LevelCrossing(order: 101, kilometre: [0.11]),
        LevelCrossing(order: 105, kilometre: [0.14]),
      ],
      otherPoints: [
        Signal(order: 103, kilometre: [0.12]),
      ],
    );

    expect(baliseGroup.shownLevelCrossingsCount(), 2);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[0]), false);
    expect(baliseGroup.shouldShowBaliseIconForLevelCrossing(baliseGroup.levelCrossings[1]), false);
  });
}

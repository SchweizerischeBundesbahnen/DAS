import 'package:app/pages/journey/journey_screen/model/journey_position_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/chevron_animation_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('test animation data calculates offsets correctly when moving forward', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 100, kilometre: []),
        Signal(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 400, kilometre: []),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(currentPosition: journeyPoints[2], lastPosition: journeyPoints[0]);

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [],
    );
    final animationData4 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[3],
      null,
      [],
    );

    // THEN
    expect(animationData1, isNotNull);
    expect(animationData1!.startOffset, 0.0);
    expect(animationData1.endOffset, 108.0);
    expect(animationData2, isNotNull);
    expect(animationData2!.startOffset, -51.5);
    expect(animationData2.endOffset, 56.5);
    expect(animationData3, isNotNull);
    expect(animationData3!.startOffset, -108.0);
    expect(animationData3.endOffset, 0.0);
    expect(animationData4, isNull);
  });

  test('test animation data calculates offsets correctly when moving backwards', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 100, kilometre: []),
        Signal(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 400, kilometre: []),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(currentPosition: journeyPoints[0], lastPosition: journeyPoints[2]);

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [],
    );
    final animationData4 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[3],
      null,
      [],
    );

    // THEN
    expect(animationData1, isNotNull);
    expect(animationData1!.startOffset, 108.0);
    expect(animationData1.endOffset, 0.0);
    expect(animationData2, isNotNull);
    expect(animationData2!.startOffset, 56.5);
    expect(animationData2.endOffset, -51.5);
    expect(animationData3, isNotNull);
    expect(animationData3!.startOffset, 0.0);
    expect(animationData3.endOffset, -108.0);
    expect(animationData4, isNull);
  });

  test('test animation data calculates offsets correctly when target position is in a collapsed group', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        Signal(order: 200, kilometre: []),
        BaliseLevelCrossingGroup(
          order: 300,
          kilometre: [],
          groupedElements: [
            Balise(order: 310, kilometre: [], amountLevelCrossings: 1),
            LevelCrossing(order: 310, kilometre: [], originalOrder: 320),
          ],
        ),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(
      currentPosition: (journeyPoints[2] as BaliseLevelCrossingGroup).groupedElements[1],
      lastPosition: journeyPoints[0],
    );

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [],
    );

    // THEN
    expect(animationData1, isNotNull);
    expect(animationData1!.startOffset, 0.0);
    expect(animationData1.endOffset, 75.5);
    expect(animationData2, isNotNull);
    expect(animationData2!.startOffset, -44.0);
    expect(animationData2.endOffset, 31.5);
    expect(animationData3, isNotNull);
    expect(animationData3!.startOffset, -75.5);
    expect(animationData3.endOffset, 0.0);
  });

  test('test animation data calculates offsets correctly when target position is in a expanded group', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        Signal(order: 200, kilometre: []),
        BaliseLevelCrossingGroup(
          order: 300,
          kilometre: [],
          groupedElements: [
            Balise(order: 310, kilometre: [], amountLevelCrossings: 1),
            LevelCrossing(order: 310, kilometre: [], originalOrder: 320),
          ],
        ),
        Balise(order: 310, kilometre: [], amountLevelCrossings: 1),
        LevelCrossing(order: 320, kilometre: []),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(
      currentPosition: (journeyPoints[2] as BaliseLevelCrossingGroup).groupedElements[1],
      lastPosition: journeyPoints[0],
    );

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [300],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [300],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [300],
    );
    final animationData4 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[3],
      null,
      [300],
    );
    final animationData5 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[4],
      null,
      [300],
    );

    // THEN
    expect(animationData1, isNotNull);
    expect(animationData1!.startOffset, 0.0);
    expect(animationData1.endOffset, 176.0);
    expect(animationData2, isNotNull);
    expect(animationData2!.startOffset, -44.0);
    expect(animationData2.endOffset, 132.0);
    expect(animationData3, isNotNull);
    expect(animationData3!.startOffset, -75.5);
    expect(animationData3.endOffset, 100.5);
    expect(animationData4, isNotNull);
    expect(animationData4!.startOffset, -132.0);
    expect(animationData4.endOffset, 44.0);
    expect(animationData5, isNotNull);
    expect(animationData5!.startOffset, -176.0);
    expect(animationData5.endOffset, 0.0);
  });

  test('test animation data is null when current position is the same as last position', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 100, kilometre: []),
        Signal(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 400, kilometre: []),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(currentPosition: journeyPoints[2], lastPosition: journeyPoints[2]);

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [],
    );
    final animationData4 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[3],
      null,
      [],
    );

    // THEN
    expect(animationData1, isNull);
    expect(animationData2, isNull);
    expect(animationData3, isNull);
    expect(animationData4, isNull);
  });

  test('test animation data is null when last position is null', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(),
      data: [
        Signal(order: 0, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 100, kilometre: []),
        Signal(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 400, kilometre: []),
      ],
    );

    final journeyPoints = journey.data.whereType<JourneyPoint>().toList();
    final journeyPosition = JourneyPositionModel(currentPosition: journeyPoints[2], lastPosition: null);

    // WHEN
    final animationData1 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[0],
      null,
      [],
    );
    final animationData2 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[1],
      null,
      [],
    );
    final animationData3 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[2],
      null,
      [],
    );
    final animationData4 = ChevronAnimationData.from(
      journeyPoints,
      journeyPosition,
      journey.metadata,
      journeyPoints[3],
      null,
      [],
    );

    // THEN
    expect(animationData1, isNull);
    expect(animationData2, isNull);
    expect(animationData3, isNull);
    expect(animationData4, isNull);
  });
}

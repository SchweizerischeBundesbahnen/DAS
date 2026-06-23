import 'package:app/extension/base_data_extension.dart';
import 'package:app/pages/journey/view_model/model/extended_train_identification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  test('addTrainDriverTurnoverRows_whenTrainIdentificationNull_thenDoNothing', () {
    // GIVEN
    final baseData = <BaseData>[
      ServicePoint(name: 'A', abbreviation: 'A', order: 0, kilometre: [0.0], locationCode: 'A'),
      ServicePoint(name: 'B', abbreviation: 'B', order: 1, kilometre: [1.0], locationCode: 'B'),
      ServicePoint(name: 'C', abbreviation: 'C', order: 2, kilometre: [2.0], locationCode: 'C'),
      ServicePoint(name: 'D', abbreviation: 'D', order: 3, kilometre: [3.0], locationCode: 'D'),
      ServicePoint(name: 'E', abbreviation: 'E', order: 4, kilometre: [4.0], locationCode: 'E'),
    ];

    final ExtendedTrainIdentification? trainIdentification = null;
    // WHEN
    final resultList = baseData.addTrainDriverTurnoverRows(trainIdentification).toList();

    // THEN
    expect(resultList, hasLength(baseData.length));
    expect(resultList[0], baseData[0]);
    expect(resultList[1], baseData[1]);
    expect(resultList[2], baseData[2]);
    expect(resultList[3], baseData[3]);
    expect(resultList[4], baseData[4]);
  });

  test('addTrainDriverTurnoverRows_whenTrainIdentificationTafTapStartAndEndIsNull_thenDoNothing', () {
    // GIVEN
    final baseData = <BaseData>[
      ServicePoint(name: 'A', abbreviation: 'A', order: 0, kilometre: [0.0], locationCode: 'A'),
      ServicePoint(name: 'B', abbreviation: 'B', order: 1, kilometre: [1.0], locationCode: 'B'),
      ServicePoint(name: 'C', abbreviation: 'C', order: 2, kilometre: [2.0], locationCode: 'C'),
      ServicePoint(name: 'D', abbreviation: 'D', order: 3, kilometre: [3.0], locationCode: 'D'),
      ServicePoint(name: 'E', abbreviation: 'E', order: 4, kilometre: [4.0], locationCode: 'E'),
    ];

    final ExtendedTrainIdentification trainIdentification = ExtendedTrainIdentification(
      trainIdentification: TrainIdentification(
        ru: .sbbP,
        trainNumber: '123',
        date: DateTime.now(),
      ),
    );
    // WHEN
    final resultList = baseData.addTrainDriverTurnoverRows(trainIdentification).toList();

    // THEN
    expect(resultList, hasLength(baseData.length));
    expect(resultList[0], baseData[0]);
    expect(resultList[1], baseData[1]);
    expect(resultList[2], baseData[2]);
    expect(resultList[3], baseData[3]);
    expect(resultList[4], baseData[4]);
  });

  test('addTrainDriverTurnoverRows_whenTrainIdentificationTafTapStartAndEndIsSet_thenAddTrainDriverTurnover', () {
    // GIVEN
    final baseData = <BaseData>[
      ServicePoint(name: 'A', abbreviation: 'A', order: 0, kilometre: [0.0], locationCode: 'A'),
      ServicePoint(name: 'B', abbreviation: 'B', order: 1, kilometre: [1.0], locationCode: 'B'),
      ServicePoint(name: 'C', abbreviation: 'C', order: 2, kilometre: [2.0], locationCode: 'C'),
      ServicePoint(name: 'D', abbreviation: 'D', order: 3, kilometre: [3.0], locationCode: 'D'),
      ServicePoint(name: 'E', abbreviation: 'E', order: 4, kilometre: [4.0], locationCode: 'E'),
    ];

    final ExtendedTrainIdentification trainIdentification = ExtendedTrainIdentification(
      trainIdentification: TrainIdentification(
        ru: .sbbP,
        trainNumber: '123',
        date: DateTime.now(),
      ),
      tafTapLocationReferenceStart: 'B',
      tafTapLocationReferenceEnd: 'D',
    );
    // WHEN
    final resultList = baseData.addTrainDriverTurnoverRows(trainIdentification).toList();
    final personalChanges = resultList.whereType<TrainDriverTurnover>().toList();

    // THEN
    expect(resultList, hasLength(7));
    expect(personalChanges, hasLength(2));
    expect(personalChanges[0].order, 1);
    expect(personalChanges[0].isStart, true);
    expect(personalChanges[1].order, 3);
    expect(personalChanges[1].isStart, false);
  });

  test(
    'addTrainDriverTurnoverRows_whenTrainIdentificationTafTapStartAndEndIsSet_thenDoesNotAddPersonChangeForFirstAndLastServicePoint',
    () {
      // GIVEN
      final baseData = <BaseData>[
        ServicePoint(name: 'A', abbreviation: 'A', order: 0, kilometre: [0.0], locationCode: 'A'),
        ServicePoint(name: 'B', abbreviation: 'B', order: 1, kilometre: [1.0], locationCode: 'B'),
        ServicePoint(name: 'C', abbreviation: 'C', order: 2, kilometre: [2.0], locationCode: 'C'),
        ServicePoint(name: 'D', abbreviation: 'D', order: 3, kilometre: [3.0], locationCode: 'D'),
        ServicePoint(name: 'E', abbreviation: 'E', order: 4, kilometre: [4.0], locationCode: 'E'),
      ];

      final ExtendedTrainIdentification trainIdentification = ExtendedTrainIdentification(
        trainIdentification: TrainIdentification(
          ru: .sbbP,
          trainNumber: '123',
          date: DateTime.now(),
        ),
        tafTapLocationReferenceStart: 'A',
        tafTapLocationReferenceEnd: 'E',
      );
      // WHEN
      final resultList = baseData.addTrainDriverTurnoverRows(trainIdentification).toList();
      final trainDriverTurnoverRows = resultList.whereType<TrainDriverTurnover>().toList();

      // THEN
      expect(resultList, hasLength(5));
      expect(trainDriverTurnoverRows, hasLength(0));
    },
  );

  test(
    'hideSignals_whenStationsSignalsIsFalse_thenDoesNothing',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 0, kilometre: [0.0], functions: [SignalFunction.entry]),
        Signal(order: 1, kilometre: [1.0], functions: [SignalFunction.exit]),
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.intermediate]),
        Signal(order: 3, kilometre: [3.0], functions: [SignalFunction.block]),
        Signal(order: 4, kilometre: [4.0], functions: [SignalFunction.protection]),
        Signal(order: 5, kilometre: [5.0], functions: [SignalFunction.laneChange]),
        Signal(order: 6, kilometre: [6.0], functions: [SignalFunction.lockingOutSignal]),
        Signal(order: 7, kilometre: [7.0], functions: [SignalFunction.trackEndSignal]),
      ];

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: false,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(8));
    },
  );

  test(
    'hideSignals_whenStationsSignalsIsTrue_thenHidesStationSignalsOnly',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 0, kilometre: [0.0], functions: [SignalFunction.entry]),
        Signal(order: 1, kilometre: [1.0], functions: [SignalFunction.exit]),
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.intermediate]),
        Signal(order: 3, kilometre: [3.0], functions: [SignalFunction.block]),
        Signal(order: 4, kilometre: [4.0], functions: [SignalFunction.protection]),
        Signal(order: 5, kilometre: [5.0], functions: [SignalFunction.laneChange]),
        Signal(order: 6, kilometre: [6.0], functions: [SignalFunction.lockingOutSignal]),
        Signal(order: 7, kilometre: [7.0], functions: [SignalFunction.trackEndSignal]),
      ];

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(4));
      expect(resultList[0], baseData[3]);
      expect(resultList[1], baseData[4]);
      expect(resultList[2], baseData[5]);
      expect(resultList[3], baseData[6]);
    },
  );

  test(
    'hideSignals_whenStationsSignalsIsTrue_thenHidesStationSignalsOnlyIfAllFunctionsMatch',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 0, kilometre: [0.0], functions: [SignalFunction.entry]),
        Signal(order: 1, kilometre: [1.0], functions: [SignalFunction.exit, SignalFunction.block]),
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.intermediate]),
        Signal(order: 3, kilometre: [3.0], functions: [SignalFunction.block]),
        Signal(order: 4, kilometre: [4.0], functions: [SignalFunction.protection]),
        Signal(order: 5, kilometre: [5.0], functions: [SignalFunction.laneChange]),
        Signal(order: 6, kilometre: [6.0], functions: [SignalFunction.lockingOutSignal]),
      ];

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(5));
      expect(resultList[0], baseData[1]);
      expect(resultList[1], baseData[3]);
      expect(resultList[2], baseData[4]);
      expect(resultList[3], baseData[5]);
      expect(resultList[4], baseData[6]);
    },
  );

  test(
    'hideSignals_whenConventionalSpeedSignalsIsTrue_thenFiltersSignals',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.etcsStopSign]),
        Signal(order: 3, kilometre: [3.0], functions: [SignalFunction.entry]),
      ];
      const segment = NonStandardTrackEquipmentSegment(
        startKm: [0.0],
        endKm: [4.0],
        startOrder: 1,
        endOrder: 4,
        type: TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
      );

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: false,
            conventionalSpeedSignals: true,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [segment],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(1));
      expect((resultList.single as Signal).order, 3);
    },
  );

  test(
    'hideSignals_whenConventionalSpeedSignalsIsFalse_thenKeepsSignalWithEtcsStopSignInConventionalSegment',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.etcsStopSign]),
      ];
      const segment = NonStandardTrackEquipmentSegment(
        startKm: [0.0],
        endKm: [3.0],
        startOrder: 1,
        endOrder: 3,
        type: TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
      );

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [segment],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(1));
      expect((resultList.single as Signal).order, 2);
    },
  );

  test(
    'hideSignals_whenExtendedSpeedSignalsIsTrue_thenFiltersSignals',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 5, kilometre: [5.0], functions: [SignalFunction.etcsStopSign]),
        Signal(order: 9, kilometre: [9.0], functions: [SignalFunction.etcsStopSign]),
      ];
      const segment = NonStandardTrackEquipmentSegment(
        startKm: [4.0],
        endKm: [6.0],
        startOrder: 4,
        endOrder: 6,
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
      );

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: true,
            nonStandardTrackEquipmentSegments: const [segment],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(1));
      expect((resultList.single as Signal).order, 9);
    },
  );

  test(
    'hideSignals_whenExtendedSpeedSignalsIsFalse_thenKeepsSignalWithEtcsStopSignInExtendedSegment',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.etcsStopSign]),
      ];
      const segment = NonStandardTrackEquipmentSegment(
        startKm: [0.0],
        endKm: [3.0],
        startOrder: 1,
        endOrder: 3,
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
      );

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: false,
            nonStandardTrackEquipmentSegments: const [segment],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(1));
      expect((resultList.single as Signal).order, 2);
    },
  );

  test(
    'hideSignals_whenSignalHasMultipleFunctions_thenOnlyHideWhenAllFunctionsAreHidden',
    () {
      // GIVEN
      final baseData = <BaseData>[
        Signal(order: 2, kilometre: [2.0], functions: [SignalFunction.entry, SignalFunction.etcsStopSign]),
        Signal(order: 3, kilometre: [3.0], functions: [SignalFunction.block, SignalFunction.etcsStopSign]),
      ];
      const segment = NonStandardTrackEquipmentSegment(
        startKm: [0.0],
        endKm: [4.0],
        startOrder: 1,
        endOrder: 4,
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
      );

      // WHEN
      final resultList = baseData
          .hideSignals(
            stationSignals: true,
            conventionalSpeedSignals: false,
            extendedSpeedSignals: true,
            nonStandardTrackEquipmentSegments: const [segment],
          )
          .toList();

      // THEN
      expect(resultList, hasLength(1));
      expect((resultList.single as Signal).order, 3);
    },
  );
}

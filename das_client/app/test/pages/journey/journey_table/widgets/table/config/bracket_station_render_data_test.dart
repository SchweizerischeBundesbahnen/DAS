import 'package:app/pages/journey/journey_table/widgets/table/config/bracket_station_render_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/bracket_station_segment.dart';
import 'package:sfera/src/model/journey/journey.dart';
import 'package:sfera/src/model/journey/metadata.dart';
import 'package:sfera/src/model/journey/service_point.dart';
import 'package:sfera/src/model/journey/signal.dart';

void main() {
  test('test BracketStationRenderData factory', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        bracketStationSegments: [
          _bracketStationSegment('D', 100, 300),
        ],
      ),
      data: [
        Signal(order: 0, kilometre: []),
        ServicePoint(name: '', order: 100, kilometre: []),
        Signal(order: 200, kilometre: []),
        ServicePoint(name: '', order: 300, kilometre: []),
        ServicePoint(name: '', order: 400, kilometre: []),
      ],
    );

    // WHEN
    final renderData1 = BracketStationRenderData.from(journey.data[0], journey.metadata);
    final renderData2 = BracketStationRenderData.from(journey.data[1], journey.metadata);
    final renderData3 = BracketStationRenderData.from(journey.data[2], journey.metadata);
    final renderData4 = BracketStationRenderData.from(journey.data[3], journey.metadata);
    final renderData5 = BracketStationRenderData.from(journey.data[4], journey.metadata);

    // THEN
    expect(renderData1, isNull);
    expect(renderData2, isNotNull);
    expect(renderData2!.isStart, isTrue);
    expect(renderData2.stationAbbreviation, 'D');
    expect(renderData3, isNotNull);
    expect(renderData3!.isStart, isFalse);
    expect(renderData3.stationAbbreviation, 'D');
    expect(renderData4, isNotNull);
    expect(renderData4!.isStart, isFalse);
    expect(renderData4.stationAbbreviation, 'D');
    expect(renderData5, isNull);
  });
}

BracketStationSegment _bracketStationSegment(String abbreviation, int startOrder, int endOrder) {
  return BracketStationSegment(mainStationAbbreviation: abbreviation, startOrder: startOrder, endOrder: endOrder);
}

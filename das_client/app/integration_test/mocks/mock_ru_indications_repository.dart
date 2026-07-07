import 'package:core_data/component.dart';
import 'package:ru_indications/component.dart';

final _smallText = 'This is a short mock RU indication description.';
final _longTextWithLink =
    'This is a long mock RU indication description containing a [link](https://example.com). Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum.';

class MockRuIndicationsRepository implements RuIndicationsRepository {
  bool shouldReturnMockData = false;

  /// Returns two mocked RU indications for first location and one for last location.
  @override
  Future<List<RuIndication>> fetchRuIndications({
    required TrainIdentification trainIdentification,
    required Map<String, int> locationReferences,
  }) async {
    if (!shouldReturnMockData || locationReferences.isEmpty) {
      return const [];
    }

    final entries = locationReferences.entries;
    return [
      RuIndication(title: entries.first.key, text: _smallText, order: entries.first.value),
      RuIndication(title: entries.first.key, text: _longTextWithLink, order: entries.first.value),
      RuIndication(title: entries.last.key, text: _smallText, order: entries.last.value),
    ];
  }
}

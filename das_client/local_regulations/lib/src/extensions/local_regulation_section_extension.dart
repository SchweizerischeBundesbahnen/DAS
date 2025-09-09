import 'package:local_regulations/src/local_regulation_relevance.dart';
import 'package:sfera/component.dart';

extension LocalRegulationSectionExtension on LocalRegulationSection {
  String toHtml() {
    final relevance = LocalRegulationRelevance.from(title.localized);
    if (relevance == null) {
      return '''
      <h3>${title.localized}</h3>
      <div>${content.localized}</div>
      ''';
    }

    final titleWithoutAbbreviation = title.localized.replaceFirst(RegExp(r'^\s*\S+\s*'), '');
    return '''
      <div class="base-row">
        <div class="col-relevance">${relevance.abbreviation}</div>
        <div class="col-content">
          <div class="title">$titleWithoutAbbreviation</div>
          <div>${content.localized}</div>
        </div>
      </div>
      ''';
  }
}

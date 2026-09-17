import 'package:local_regulations/src/local_regulation_relevance.dart';
import 'package:sfera/component.dart';

extension LocalRegulationSectionExtension on LocalRegulationSection {
  String toHtml() {
    final relevance = LocalRegulationRelevance.from(title);
    if (relevance == null) {
      return '''
      ${title != null && title!.isNotEmpty ? '<h3>$title</h3>' : ''}
      ${content != null && content!.isNotEmpty ? '<div>$content</div>' : ''}
      ''';
    }

    final titleWithoutAbbreviation = title?.replaceFirst(RegExp(r'^\s*\S+\s*'), '');
    return '''
      <div class="base-row">
        <div class="col-relevance">${relevance.abbreviation}</div>
        <div class="col-content">
          <div class="title">$titleWithoutAbbreviation</div>
          ${content != null && content!.isNotEmpty ? '<div>$content</div>' : ''}
        </div>
      </div>
      ''';
  }
}

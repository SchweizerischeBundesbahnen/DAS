package ch.sbb.das.backend.admin.domain.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatch;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationMatchesRequest;
import java.util.List;

public interface RuIndicationMatchService {

    List<RuIndicationMatch> findMatches(RuIndicationMatchesRequest filterRequest, String acceptLanguage);
}


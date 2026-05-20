package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.NoticeMatch;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesRequest;
import java.util.List;

public interface NoticeMatchService {

    List<NoticeMatch> findMatches(NoticeMatchesRequest filterRequest, String acceptLanguage);
}


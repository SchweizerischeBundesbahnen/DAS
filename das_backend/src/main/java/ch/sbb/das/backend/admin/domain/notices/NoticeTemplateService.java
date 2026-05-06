package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateRequest;
import java.util.List;

public interface NoticeTemplateService {

    List<NoticeTemplate> getAll();

    NoticeTemplate getById(Integer id);

    NoticeTemplate update(Integer id, NoticeTemplateRequest updateRequest);

    NoticeTemplate create(NoticeTemplateRequest createRequest);

    void delete(Integer id);

    void delete(List<Integer> ids);
}

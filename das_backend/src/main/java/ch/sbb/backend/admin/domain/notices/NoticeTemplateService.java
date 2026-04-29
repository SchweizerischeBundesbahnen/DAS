package ch.sbb.backend.admin.domain.notices;

import ch.sbb.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.backend.admin.application.notices.model.NoticeTemplateRequest;
import java.util.List;

public interface NoticeTemplateService {

    List<NoticeTemplate> getAll();

    NoticeTemplate getById(Integer id);

    NoticeTemplate update(Integer id, NoticeTemplateRequest updateRequest);

    NoticeTemplate create(NoticeTemplateRequest createRequest);

    void delete(Integer id);
}

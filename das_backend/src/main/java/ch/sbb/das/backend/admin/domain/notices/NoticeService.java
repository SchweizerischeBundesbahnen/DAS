package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeRequest;
import java.util.List;

public interface NoticeService {

    List<Notice> getAll();

    Notice getById(Integer id);

    Notice create(NoticeRequest createRequest);

    Notice update(Integer id, NoticeRequest updateRequest);

    void delete(Integer id);

    void delete(List<Integer> ids);
}

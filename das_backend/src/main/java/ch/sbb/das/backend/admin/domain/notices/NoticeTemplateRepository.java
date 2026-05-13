package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplate;
import java.util.List;
import java.util.Optional;

public interface NoticeTemplateRepository {

    List<NoticeTemplate> findAll();

    Optional<NoticeTemplate> findById(Integer id);

    NoticeTemplate save(NoticeTemplate appVersion);

    void deleteById(Integer id);

    void deleteAllById(Iterable<Integer> ids);

}

package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import java.util.List;
import java.util.Optional;

public interface NoticeRepository {

    List<Notice> findAll();

    Optional<Notice> findById(Integer id);

    List<Notice> findAllById(Iterable<Integer> ids);

    Notice save(Notice notice);

    void deleteById(Integer id);

    void deleteAllById(Iterable<Integer> ids);
}


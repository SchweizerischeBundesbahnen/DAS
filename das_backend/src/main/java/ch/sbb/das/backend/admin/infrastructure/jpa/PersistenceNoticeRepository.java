package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.domain.notices.NoticeRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceNoticeRepository implements NoticeRepository {

    private final SpringDataJpaNoticeRepository noticeRepository;

    PersistenceNoticeRepository(SpringDataJpaNoticeRepository noticeRepository) {
        this.noticeRepository = noticeRepository;
    }

    @Override
    public List<Notice> findAll() {
        return noticeRepository.findAll().stream().map(NoticeEntity::toNotice).toList();
    }

    @Override
    public Optional<Notice> findById(Integer id) {
        return noticeRepository.findById(id).map(NoticeEntity::toNotice);
    }

    @Override
    public List<Notice> findAllById(Iterable<Integer> ids) {
        return noticeRepository.findAllById(ids).stream().map(NoticeEntity::toNotice).toList();
    }

    @Override
    public Notice save(Notice notice) {
        return noticeRepository.save(NoticeEntity.from(notice)).toNotice();
    }

    @Override
    public void deleteById(Integer id) {
        noticeRepository.deleteById(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        noticeRepository.deleteAllById(ids);
    }
}


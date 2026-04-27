package ch.sbb.das.backend.admin.infrastructure.jpa;

import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.das.backend.admin.domain.notices.NoticeTemplateRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Component;

@Component
class PersistenceNoticeTemplateRepository implements NoticeTemplateRepository {

    private final SpringDataJpaNoticeTemplateRepository noticeTemplateRepository;

    PersistenceNoticeTemplateRepository(SpringDataJpaNoticeTemplateRepository noticeTemplateRepository) {
        this.noticeTemplateRepository = noticeTemplateRepository;
    }

    @Override
    public List<NoticeTemplate> findAll() {
        return noticeTemplateRepository.findAll().stream().map(NoticeTemplateEntity::toNoticeTemplate).toList();
    }

    @Override
    public Optional<NoticeTemplate> findById(Integer id) {
        return noticeTemplateRepository.findById(id).map(NoticeTemplateEntity::toNoticeTemplate);
    }

    @Override
    public NoticeTemplate save(NoticeTemplate noticeTemplate) {
        NoticeTemplateEntity entity = new NoticeTemplateEntity();
        entity.setId(noticeTemplate.id());
        entity.setCategory(noticeTemplate.category());
        if (noticeTemplate.de() != null) {
            entity.setTitleDe(noticeTemplate.de().title());
            entity.setTextDe(noticeTemplate.de().text());
        }
        if (noticeTemplate.fr() != null) {
            entity.setTitleFr(noticeTemplate.fr().title());
            entity.setTextFr(noticeTemplate.fr().text());
        }
        if (noticeTemplate.it() != null) {
            entity.setTitleIt(noticeTemplate.it().title());
            entity.setTextIt(noticeTemplate.it().text());
        }
        NoticeTemplateEntity saved = noticeTemplateRepository.save(entity);
        return saved.toNoticeTemplate();
    }

    @Override
    public void deleteById(Integer id) {
        noticeTemplateRepository.deleteById(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        noticeTemplateRepository.deleteAllById(ids);
    }

}

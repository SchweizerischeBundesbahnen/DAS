package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.das.backend.admin.application.notices.model.NoticeTemplateRequest;
import ch.sbb.das.backend.admin.infrastructure.jpa.NoticeTemplateEntity;
import java.util.List;
import java.util.Optional;

public class NoticeTemplateServiceImpl implements NoticeTemplateService {

    private final NoticeTemplateRepository noticeTemplateRepository;

    public NoticeTemplateServiceImpl(NoticeTemplateRepository noticeTemplateRepository) {
        this.noticeTemplateRepository = noticeTemplateRepository;
    }

    @Override
    public List<NoticeTemplate> getAll() {
        return noticeTemplateRepository.findAll();
    }

    @Override
    public NoticeTemplate getById(Integer id) {
        Optional<NoticeTemplate> optionalNoticeTemplate = noticeTemplateRepository.findById(id);
        return optionalNoticeTemplate.orElse(null);
    }

    @Override
    public NoticeTemplate create(NoticeTemplateRequest createRequest) {
        NoticeTemplateEntity entity = NoticeTemplateEntity.from(createRequest);
        return noticeTemplateRepository.save(entity.toNoticeTemplate());
    }

    @Override
    public NoticeTemplate update(Integer id, NoticeTemplateRequest updateRequest) {
        Optional<NoticeTemplate> optional = noticeTemplateRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        NoticeTemplate old = optional.get();
        NoticeTemplate updated = new NoticeTemplate(
            old.id(),
            updateRequest.category(),
            updateRequest.de(),
            updateRequest.fr(),
            updateRequest.it()
        );
        return noticeTemplateRepository.save(updated);
    }

    @Override
    public void delete(Integer id) {
        noticeTemplateRepository.deleteById(id);
    }

    @Override
    public void delete(List<Integer> ids) {
        noticeTemplateRepository.deleteAllById(ids.stream().distinct().toList());
    }
}

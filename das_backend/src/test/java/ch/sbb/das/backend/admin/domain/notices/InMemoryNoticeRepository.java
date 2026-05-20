package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

class InMemoryNoticeRepository implements NoticeRepository {

    private final AtomicInteger idSequence = new AtomicInteger(1);
    private final Map<Integer, Notice> notices = new LinkedHashMap<>();

    @Override
    public List<Notice> findAll() {
        return new ArrayList<>(notices.values());
    }

    @Override
    public Optional<Notice> findById(Integer id) {
        return Optional.ofNullable(notices.get(id));
    }

    @Override
    public List<Notice> findAllById(Iterable<Integer> ids) {
        List<Notice> result = new ArrayList<>();
        for (Integer id : ids) {
            Notice notice = notices.get(id);
            if (notice != null) {
                result.add(notice);
            }
        }
        return result;
    }

    @Override
    public Notice save(Notice notice) {
        Integer id = notice.id() == null ? idSequence.getAndIncrement() : notice.id();
        Notice persisted = new Notice(id, notice.content(), notice.scope(), notice.periods(), notice.lastModifiedAt(), notice.lastModifiedBy());
        notices.put(id, persisted);
        return persisted;
    }

    @Override
    public void deleteById(Integer id) {
        notices.remove(id);
    }

    @Override
    public void deleteAllById(Iterable<Integer> ids) {
        for (Integer id : ids) {
            notices.remove(id);
        }
    }
}


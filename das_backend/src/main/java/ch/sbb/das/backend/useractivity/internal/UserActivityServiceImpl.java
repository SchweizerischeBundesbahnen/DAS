package ch.sbb.das.backend.useractivity.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.useractivity.UserActivityService;
import java.time.OffsetDateTime;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
class UserActivityServiceImpl implements UserActivityService {

    private final UserActivityRepository userActivityRepository;

    @Override
    @Transactional
    public void recordAccess(String oid) {
        if (!StringUtils.hasText(oid)) {
            return;
        }
        UserActivityEntity entity = userActivityRepository.findByOid(oid)
            .orElseGet(() -> {
                UserActivityEntity newEntity = new UserActivityEntity();
                newEntity.setOid(oid);
                return newEntity;
            });
        entity.setLastAccessedAt(DateTimeUtil.now());
        try {
            userActivityRepository.save(entity);
        } catch (DataIntegrityViolationException _) {
            // A concurrent request may have inserted the same oid first (unique constraint on oid).
            // Recording access is best-effort, so the losing thread simply skips its own insert.
        }
    }

    @Override
    public List<String> findInactiveOids(long olderThanDays) {
        OffsetDateTime threshold = DateTimeUtil.now().minusDays(olderThanDays);
        return userActivityRepository.findAllByLastAccessedAtBefore(threshold).stream()
            .map(UserActivityEntity::getOid)
            .toList();
    }
}

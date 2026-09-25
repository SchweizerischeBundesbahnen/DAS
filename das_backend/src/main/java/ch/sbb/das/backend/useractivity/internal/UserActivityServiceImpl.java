package ch.sbb.das.backend.useractivity.internal;

import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.useractivity.UserActivityService;
import lombok.RequiredArgsConstructor;
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
        userActivityRepository.recordAccess(oid, DateTimeUtil.today());
    }
}

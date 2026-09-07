package ch.sbb.das.backend.useractivity.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.IntegrationTest;
import java.util.Optional;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.core.SimpleLock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.context.jdbc.SqlMergeMode.MergeMode;

@IntegrationTest
@Sql("classpath:emptyUserActivity.sql")
@SqlMergeMode(MergeMode.MERGE)
class UserActivityCleanUpSchedulerIntegrationTest {

    private static final String INACTIVE_OID = "11111111-1111-1111-1111-111111111111";
    private static final String ACTIVE_OID = "22222222-2222-2222-2222-222222222222";
    private static final String WITHIN_BUFFER_OID = "33333333-3333-3333-3333-333333333333";

    @MockitoBean
    private LockProvider lockProvider;

    @Autowired
    private UserActivityCleanUpScheduler cleanUpScheduler;

    @Autowired
    private UserActivityRepository userActivityRepository;

    @BeforeEach
    void setUp() {
        SimpleLock dummyLock = mock(SimpleLock.class);
        when(lockProvider.lock(any())).thenReturn(Optional.of(dummyLock));
    }

    @DisplayName("cleanUpUserActivity_removesInactiveRecords_keepsActive|rNAcBZnWglFBAYQGM9aL|tests:2133")
    @Test
    @Sql("classpath:createUserActivityInactiveAndActive.sql")
    void cleanUpUserActivity_removesInactiveRecords_keepsActive() {
        assertThat(userActivityRepository.count()).isEqualTo(2);

        cleanUpScheduler.cleanUpUserActivity();

        assertThat(userActivityRepository.findByOid(INACTIVE_OID)).isEmpty();
        assertThat(userActivityRepository.findByOid(ACTIVE_OID)).isPresent();
    }

    @DisplayName("cleanUpUserActivity_doesNothing_whenNoInactiveUsers|0cajArCpmGu1X2uyKdOh|tests:2133")
    @Test
    @Sql("classpath:createUserActivityActiveOnly.sql")
    void cleanUpUserActivity_doesNothing_whenNoInactiveUsers() {
        cleanUpScheduler.cleanUpUserActivity();

        assertThat(userActivityRepository.count()).isEqualTo(1);
    }

    @DisplayName("cleanUpUserActivity_keepsRecordWithinRetentionBuffer|W3Vqg5K6OjG36YS4Ah7w|tests:2133")
    @Test
    @Sql("classpath:createUserActivityWithinRetentionBuffer.sql")
    void cleanUpUserActivity_keepsRecordWithinRetentionBuffer() {
        cleanUpScheduler.cleanUpUserActivity();

        assertThat(userActivityRepository.findByOid(WITHIN_BUFFER_OID)).isPresent();
    }
}

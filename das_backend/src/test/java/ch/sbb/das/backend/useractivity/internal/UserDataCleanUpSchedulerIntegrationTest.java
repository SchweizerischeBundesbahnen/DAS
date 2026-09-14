package ch.sbb.das.backend.useractivity.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.IntegrationTest;
import java.util.Objects;
import java.util.Optional;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.core.SimpleLock;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.jdbc.SqlMergeMode;
import org.springframework.test.context.jdbc.SqlMergeMode.MergeMode;

@IntegrationTest
@Sql({"classpath:emptyUserActivity.sql", "classpath:emptyPersonalNotes.sql", "classpath:emptyUserProperties.sql"})
@SqlMergeMode(MergeMode.MERGE)
class UserDataCleanUpSchedulerIntegrationTest {

    private static final String INACTIVE_OID = "11111111-1111-1111-1111-111111111111";
    private static final String ACTIVE_OID = "22222222-2222-2222-2222-222222222222";

    @MockitoBean
    private LockProvider lockProvider;

    @Autowired
    private UserDataCleanUpScheduler userDataCleanUpScheduler;

    @Autowired
    private UserActivityRepository userActivityRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() {
        SimpleLock dummyLock = mock(SimpleLock.class);
        when(lockProvider.lock(any())).thenReturn(Optional.of(dummyLock));
    }

    @DisplayName("cleanUp_deletesAllDataOfInactiveUser_keepsActiveUser|AnraXtxWuTGiJOaEv0lv|tests:2133")
    @Test
    @Sql({"classpath:createUserActivityInactiveAndActive.sql", "classpath:createPersonalNotesInactiveAndActive.sql", "classpath:createUserPropertiesInactiveAndActive.sql"})
    void cleanUp_deletesAllDataOfInactiveUser_keepsActiveUser() {
        userDataCleanUpScheduler.cleanUpInactiveUserData();

        assertThat(countPersonalNotesForOid(INACTIVE_OID)).isZero();
        assertThat(countUserPropertiesForOid(INACTIVE_OID)).isZero();
        assertThat(userActivityRepository.findByOid(INACTIVE_OID)).isEmpty();

        assertThat(countPersonalNotesForOid(ACTIVE_OID)).isEqualTo(1);
        assertThat(countUserPropertiesForOid(ACTIVE_OID)).isEqualTo(1);
        assertThat(userActivityRepository.findByOid(ACTIVE_OID)).isPresent();
    }

    private long countPersonalNotesForOid(String oid) {
        return query("SELECT COUNT(*) FROM personal_note WHERE oid = ?", oid);
    }

    private long countUserPropertiesForOid(String oid) {
        return query("SELECT COUNT(*) FROM user_property WHERE oid = ?", oid);
    }

    private long query(String sql, Object... args) {
        return Objects.requireNonNullElse(jdbcTemplate.queryForObject(sql, Long.class, args), 0L);
    }
}

package ch.sbb.das.backend.userproperties.internal;

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
@Sql({"classpath:emptyUserActivity.sql", "classpath:emptyUserProperties.sql"})
@SqlMergeMode(MergeMode.MERGE)
class UserPropertyCleanUpSchedulerIntegrationTest {

    private static final String INACTIVE_OID = "11111111-1111-1111-1111-111111111111";
    private static final String ACTIVE_OID = "22222222-2222-2222-2222-222222222222";

    @MockitoBean
    private LockProvider lockProvider;

    @Autowired
    private UserPropertyCleanUpScheduler cleanUpScheduler;

    @Autowired
    private UserPropertyRepository userPropertyRepository;

    @BeforeEach
    void setUp() {
        SimpleLock dummyLock = mock(SimpleLock.class);
        when(lockProvider.lock(any())).thenReturn(Optional.of(dummyLock));
    }

    @DisplayName("cleanUp_deletesPropertiesOfInactiveUsers_keepsActive|FrRyO1tC3fXJ3w2ep6BL|tests:2133")
    @Test
    @Sql({"classpath:createUserActivityInactiveAndActive.sql", "classpath:createUserPropertiesInactiveAndActive.sql"})
    void cleanUp_deletesPropertiesOfInactiveUsers_keepsActive() {
        assertThat(userPropertyRepository.count()).isEqualTo(2);

        cleanUpScheduler.cleanUpInactiveUsersProperties();

        assertThat(userPropertyRepository.findByOidAndKey(INACTIVE_OID, "prop-key")).isEmpty();
        assertThat(userPropertyRepository.findByOidAndKey(ACTIVE_OID, "prop-key")).isPresent();
    }

    @DisplayName("cleanUp_doesNothing_whenNoInactiveUsers|vPFQF6tQ7WmnGe036J9x|tests:2133")
    @Test
    @Sql({"classpath:createUserActivityActiveOnly.sql", "classpath:createUserPropertiesInactiveAndActive.sql"})
    void cleanUp_doesNothing_whenNoInactiveUsers() {
        cleanUpScheduler.cleanUpInactiveUsersProperties();

        assertThat(userPropertyRepository.count()).isEqualTo(2);
    }
}

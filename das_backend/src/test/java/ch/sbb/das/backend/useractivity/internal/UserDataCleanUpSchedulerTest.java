package ch.sbb.das.backend.useractivity.internal;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.UserDataService;
import java.time.LocalDate;
import java.util.List;
import net.javacrumbs.shedlock.core.LockAssert;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class UserDataCleanUpSchedulerTest {

    private static final long OLDER_THAN_DAYS = 180;

    @Mock
    private UserActivityRepository userActivityRepository;
    @Mock
    private UserDataService firstCleaner;
    @Mock
    private UserDataService secondCleaner;

    private UserDataCleanUpScheduler underTest;

    @BeforeEach
    void setUp() {
        LockAssert.TestHelper.makeAllAssertsPass(true);
        underTest = new UserDataCleanUpScheduler(userActivityRepository, List.of(firstCleaner, secondCleaner));
        ReflectionTestUtils.setField(underTest, "cleanUpOlderThanDays", OLDER_THAN_DAYS);
    }

    @Test
    void cleanUp_deletesFromEveryCleanerAndActivityRecords_forInactiveOids() {
        UserActivityEntity inactive = new UserActivityEntity();
        inactive.setOid("inactive-oid");
        when(userActivityRepository.findAllByLastAccessedOnBefore(any(LocalDate.class)))
            .thenReturn(List.of(inactive));

        underTest.cleanUpInactiveUserData();

        List<String> expectedOids = List.of("inactive-oid");
        verify(firstCleaner).deleteAllByOids(expectedOids);
        verify(secondCleaner).deleteAllByOids(expectedOids);
        verify(userActivityRepository).deleteByOidIn(expectedOids);
    }

    @Test
    void cleanUp_deletesNothing_whenNoInactiveUsers() {
        when(userActivityRepository.findAllByLastAccessedOnBefore(any(LocalDate.class)))
            .thenReturn(List.of());

        underTest.cleanUpInactiveUserData();

        verifyNoInteractions(firstCleaner);
        verifyNoInteractions(secondCleaner);
        verify(userActivityRepository, never()).deleteByOidIn(anyList());
    }
}

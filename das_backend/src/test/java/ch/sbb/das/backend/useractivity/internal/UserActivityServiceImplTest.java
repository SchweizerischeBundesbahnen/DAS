package ch.sbb.das.backend.useractivity.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.LocalDate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class UserActivityServiceImplTest {

    private UserActivityRepository userActivityRepository;
    private UserActivityServiceImpl underTest;

    @BeforeEach
    void setUp() {
        userActivityRepository = mock(UserActivityRepository.class);
        underTest = new UserActivityServiceImpl(userActivityRepository);
    }

    @Test
    void recordAccess_upsertsWithTodaysDate() {
        underTest.recordAccess("oid-1");

        ArgumentCaptor<LocalDate> today = ArgumentCaptor.forClass(LocalDate.class);
        verify(userActivityRepository).recordAccess(eq("oid-1"), today.capture());
        assertThat(today.getValue()).isEqualTo(DateTimeUtil.today());
    }

    @Test
    void recordAccess_ignoresBlankOid() {
        underTest.recordAccess("  ");
        underTest.recordAccess(null);

        verify(userActivityRepository, never()).recordAccess(any(), any());
    }
}

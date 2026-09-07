package ch.sbb.das.backend.useractivity.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
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
    void recordAccess_createsNewEntry_whenNoneExists() {
        when(userActivityRepository.findByOid("oid-1")).thenReturn(Optional.empty());

        underTest.recordAccess("oid-1");

        ArgumentCaptor<UserActivityEntity> captor = ArgumentCaptor.forClass(UserActivityEntity.class);
        verify(userActivityRepository).save(captor.capture());
        assertThat(captor.getValue().getOid()).isEqualTo("oid-1");
        assertThat(captor.getValue().getLastAccessedAt()).isNotNull();
        assertThat(captor.getValue().getId()).isNull();
    }

    @Test
    void recordAccess_updatesExistingEntry_keepsSingleRowPerUser() {
        UserActivityEntity existing = new UserActivityEntity();
        existing.setId(42);
        existing.setOid("oid-1");
        existing.setLastAccessedAt(DateTimeUtil.now().minusDays(200));
        when(userActivityRepository.findByOid("oid-1")).thenReturn(Optional.of(existing));

        underTest.recordAccess("oid-1");

        ArgumentCaptor<UserActivityEntity> captor = ArgumentCaptor.forClass(UserActivityEntity.class);
        verify(userActivityRepository).save(captor.capture());
        assertThat(captor.getValue().getId()).isEqualTo(42);
        assertThat(captor.getValue().getLastAccessedAt()).isAfter(DateTimeUtil.now().minusDays(1));
    }

    @Test
    void recordAccess_ignoresBlankOid() {
        underTest.recordAccess("  ");
        underTest.recordAccess(null);

        verify(userActivityRepository, never()).findByOid(any());
        verify(userActivityRepository, never()).save(any());
    }

    @Test
    void findInactiveOids_returnsOidsBeforeThreshold() {
        UserActivityEntity inactive = new UserActivityEntity();
        inactive.setOid("inactive-oid");
        when(userActivityRepository.findAllByLastAccessedAtBefore(any(OffsetDateTime.class)))
            .thenReturn(List.of(inactive));

        List<String> result = underTest.findInactiveOids(180);

        assertThat(result).containsExactly("inactive-oid");
        ArgumentCaptor<OffsetDateTime> captor = ArgumentCaptor.forClass(OffsetDateTime.class);
        verify(userActivityRepository).findAllByLastAccessedAtBefore(captor.capture());
        assertThat(captor.getValue()).isBefore(DateTimeUtil.now().minusDays(179));
    }
}

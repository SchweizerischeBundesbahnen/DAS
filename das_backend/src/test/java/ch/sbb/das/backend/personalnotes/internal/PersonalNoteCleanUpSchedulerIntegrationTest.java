package ch.sbb.das.backend.personalnotes.internal;

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
@Sql({"classpath:emptyUserActivity.sql", "classpath:emptyPersonalNotes.sql"})
@SqlMergeMode(MergeMode.MERGE)
class PersonalNoteCleanUpSchedulerIntegrationTest {

    private static final String INACTIVE_OID = "11111111-1111-1111-1111-111111111111";
    private static final String ACTIVE_OID = "22222222-2222-2222-2222-222222222222";

    @MockitoBean
    private LockProvider lockProvider;

    @Autowired
    private PersonalNoteCleanUpScheduler cleanUpScheduler;

    @Autowired
    private PersonalNoteRepository personalNoteRepository;

    @BeforeEach
    void setUp() {
        SimpleLock dummyLock = mock(SimpleLock.class);
        when(lockProvider.lock(any())).thenReturn(Optional.of(dummyLock));
    }

    @DisplayName("cleanUp_deletesNotesOfInactiveUsers_keepsActive|AnraXtxWuTGiJOaEv0lv|tests:2133")
    @Test
    @Sql({"classpath:createUserActivityInactiveAndActive.sql", "classpath:createPersonalNotesInactiveAndActive.sql"})
    void cleanUp_deletesNotesOfInactiveUsers_keepsActive() {
        assertThat(personalNoteRepository.count()).isEqualTo(2);

        cleanUpScheduler.cleanUpInactiveUsersNotes();

        assertThat(personalNoteRepository.findByOidAndKey(INACTIVE_OID, "note-key")).isEmpty();
        assertThat(personalNoteRepository.findByOidAndKey(ACTIVE_OID, "note-key")).isPresent();
    }

    @DisplayName("cleanUp_doesNothing_whenNoInactiveUsers|bCAZ5yPJIpKLObYDrtAc|tests:2133")
    @Test
    @Sql({"classpath:createUserActivityActiveOnly.sql", "classpath:createPersonalNotesInactiveAndActive.sql"})
    void cleanUp_doesNothing_whenNoInactiveUsers() {
        cleanUpScheduler.cleanUpInactiveUsersNotes();

        assertThat(personalNoteRepository.count()).isEqualTo(2);
    }
}

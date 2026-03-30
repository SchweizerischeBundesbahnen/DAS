package ch.sbb.backend.admin.domain.settings;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.backend.admin.application.settings.model.request.AppVersionRequest;
import ch.sbb.backend.admin.application.settings.model.response.AppVersion;
import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.backend.admin.infrastructure.jpa.AppVersionEntity;
import ch.sbb.backend.common.ConflictException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AppVersionServiceImplTest {

    private AppVersionServiceImpl underTest;
    private AppVersionRepository appVersionRepository;

    @BeforeEach
    void setUp() {
        appVersionRepository = mock(AppVersionRepository.class);
        underTest = new AppVersionServiceImpl(appVersionRepository);
        AppVersionEntity version100 = new AppVersionEntity(0, "1.0.0", true, null, null, null);
        AppVersionEntity version103 = new AppVersionEntity(1, "1.0.3", false, null, null, null);
        AppVersionEntity version110 = new AppVersionEntity(2, "1.1.0", false, LocalDate.now().plusDays(10), null, null);
        AppVersionEntity version1101 = new AppVersionEntity(3, "0.10.1", true, LocalDate.now().minusDays(10), null, null);
        AppVersionEntity version150 = new AppVersionEntity(4, "1.5.0", true, LocalDate.now().plusDays(100), null, null);
        when(appVersionRepository.findAll()).thenReturn(
            List.of(version100.toAppVersion(), version103.toAppVersion(), version110.toAppVersion(), version1101.toAppVersion(), version150.toAppVersion()));
    }

    @Test
    void getCurrent_isOk() {
        CurrentAppVersion result = underTest.getCurrent("1.0.0");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isFalse();
        assertThat(result.expiryDate()).isEqualTo(LocalDate.now().plusDays(100));

    }

    @Test
    void getCurrent_isBlockedByMinimalVersion() {
        CurrentAppVersion result = underTest.getCurrent("0.10.2");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isTrue();
    }

    @Test
    void getCurrent_isBlockedByExactVersion() {
        CurrentAppVersion result = underTest.getCurrent("1.0.3");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isTrue();
    }

    @Test
    void getCurrent_expiryDateByExactVersion() {
        CurrentAppVersion result = underTest.getCurrent("1.1.0");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isFalse();
        assertThat(result.expiryDate()).isEqualTo(LocalDate.now().plusDays(10));
    }

    @Test
    void getCurrent_expiryDateByMinimalVersion() {
        AppVersionEntity version150 = new AppVersionEntity(4, "1.5.0", true, LocalDate.now().plusDays(100), null, null);
        when(appVersionRepository.findAll()).thenReturn(List.of(version150.toAppVersion()));

        CurrentAppVersion result = underTest.getCurrent("1.3.0");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isFalse();
        assertThat(result.expiryDate()).isEqualTo(LocalDate.now().plusDays(100));
    }

    @Test
    void getCurrent_invalidVersion() {
        assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> underTest.getCurrent("invalid"));
    }

    @Test
    void getCurrent_null() {
        CurrentAppVersion result = underTest.getCurrent(null);

        assertThat(result).isEqualTo(CurrentAppVersion.DEFAULT);
    }

    @Test
    void create_checkUnique_throwsConflictExceptionWhenVersionExists() {
        AppVersionRequest request = new AppVersionRequest("1.5.0", true, LocalDate.now().plusDays(5));
        when(appVersionRepository.existsByVersion("1.5.0", null)).thenReturn(true);

        assertThatExceptionOfType(ConflictException.class)
            .isThrownBy(() -> underTest.create(request))
            .withMessage("Version already exists");

        verify(appVersionRepository).existsByVersion("1.5.0", null);
        verify(appVersionRepository, never()).save(any());
    }

    @Test
    void update_checkUnique_throwsConflictExceptionWhenVersionExists() {
        AppVersionRequest request = new AppVersionRequest("1.5.0", true, LocalDate.now().plusDays(5));
        when(appVersionRepository.findById(42)).thenReturn(Optional.of(new AppVersion(42, "1.5.0", true, LocalDate.now().plusDays(4))));
        when(appVersionRepository.existsByVersion("1.5.0", 42)).thenReturn(true);

        assertThatExceptionOfType(ConflictException.class)
            .isThrownBy(() -> underTest.update(42, request))
            .withMessage("Version already exists");

        verify(appVersionRepository).findById(42);
        verify(appVersionRepository).existsByVersion("1.5.0", 42);
        verify(appVersionRepository, never()).save(any());
    }
}

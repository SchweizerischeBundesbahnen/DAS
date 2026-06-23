package ch.sbb.das.backend.appversions.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.appversions.CurrentAppVersion;
import ch.sbb.das.backend.common.ConflictException;
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
        AppVersionEntity version100 = new AppVersionEntity(0, "1.0.0", true, null);
        AppVersionEntity version103 = new AppVersionEntity(1, "1.0.3", false, null);
        AppVersionEntity version110 = new AppVersionEntity(2, "1.1.0", false, LocalDate.now().plusDays(10));
        AppVersionEntity version1101 = new AppVersionEntity(3, "0.10.1", true, LocalDate.now().minusDays(10));
        AppVersionEntity version150 = new AppVersionEntity(4, "1.5.0", true, LocalDate.now().plusDays(100));
        AppVersionEntity version200 = new AppVersionEntity(5, "2.0.0", false, LocalDate.now());
        when(appVersionRepository.findAll()).thenReturn(
            List.of(version100, version103, version110, version1101, version150, version200));
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
    void getCurrent_expiryDateByExactVersionTodayBoundary() {
        CurrentAppVersion result = underTest.getCurrent("2.0.0");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isTrue();
        assertThat(result.expiryDate()).isNull();
    }

    @Test
    void getCurrent_expiryDateByMinimalVersion() {
        AppVersionEntity version150 = new AppVersionEntity(4, "1.5.0", true, LocalDate.now().plusDays(100));
        when(appVersionRepository.findAll()).thenReturn(List.of(version150));

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
        when(appVersionRepository.existsByVersionAndIdNot("1.5.0", null)).thenReturn(true);

        assertThatExceptionOfType(ConflictException.class)
            .isThrownBy(() -> underTest.create(request))
            .withMessage("Version already exists");

        verify(appVersionRepository).existsByVersionAndIdNot("1.5.0", null);
        verify(appVersionRepository, never()).save(any());
    }

    @Test
    void update_checkUnique_throwsConflictExceptionWhenVersionExists() {
        AppVersionRequest request = new AppVersionRequest("1.5.0", true, LocalDate.now().plusDays(5));
        when(appVersionRepository.findById(42)).thenReturn(Optional.of(new AppVersionEntity(42, "1.5.0", true, LocalDate.now().plusDays(4))));
        when(appVersionRepository.existsByVersionAndIdNot("1.5.0", 42)).thenReturn(true);

        assertThatExceptionOfType(ConflictException.class)
            .isThrownBy(() -> underTest.update(42, request))
            .withMessage("Version already exists");

        verify(appVersionRepository).findById(42);
        verify(appVersionRepository).existsByVersionAndIdNot("1.5.0", 42);
        verify(appVersionRepository, never()).save(any());
    }
}

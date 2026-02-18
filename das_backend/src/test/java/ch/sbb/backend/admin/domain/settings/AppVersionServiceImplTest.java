package ch.sbb.backend.admin.domain.settings;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ch.sbb.backend.admin.application.settings.model.response.CurrentAppVersion;
import ch.sbb.backend.admin.infrastructure.settings.AppVersionRepository;
import ch.sbb.backend.admin.infrastructure.settings.model.AppVersionEntity;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class AppVersionServiceImplTest {

    private AppVersionRepository appVersionRepository;
    private AppVersionServiceImpl underTest;

    @BeforeEach
    void setUp() {
        appVersionRepository = mock(AppVersionRepository.class);
        underTest = new AppVersionServiceImpl(appVersionRepository);
        AppVersionEntity version100 = new AppVersionEntity(0, "1.0.0", true, null);
        AppVersionEntity version103 = new AppVersionEntity(1, "1.0.3", false, null);
        AppVersionEntity version110 = new AppVersionEntity(2, "1.1.0", false, LocalDate.now().plusDays(10));
        AppVersionEntity version1101 = new AppVersionEntity(3, "0.10.1", true, LocalDate.now().minusDays(10));
        when(appVersionRepository.findAll()).thenReturn(List.of(version100, version103, version110, version1101));
    }

    @Test
    void getCurrent_isOk() {
        CurrentAppVersion result = underTest.getCurrent("1.0.0");

        assertThat(result).isNotNull();
        assertThat(result.expired()).isFalse();
        assertThat(result.expiryDate()).isNull();
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

}

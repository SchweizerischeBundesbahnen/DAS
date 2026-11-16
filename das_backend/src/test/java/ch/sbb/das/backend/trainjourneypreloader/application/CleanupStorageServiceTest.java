package ch.sbb.das.backend.trainjourneypreloader.application;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class CleanupStorageServiceTest {

    @Mock
    private S3Service s3Service;

    private CleanupStorageService underTest;

    @BeforeEach
    void setUp() {
        underTest = new CleanupStorageService(s3Service);
    }

    @Test
    void deleteAllBefore() {
        when(s3Service.listObjects()).thenReturn(List.of("2026-02-20T08-00-00Z.zip", "2026-02-20T05-00-20Z.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 20, 6, 1, 0, 0, ZoneOffset.ofHours(1)));

        verify(s3Service).deleteObjects(List.of("2026-02-20T05-00-20Z.zip"));
    }

    @Test
    void deleteAllBefore_withInvalidFiles() {
        when(s3Service.listObjects()).thenReturn(List.of("myInvalidFile.das", "2026-01-01T18-21-49Z.zip", "2026-99-01T18-21-49Z.zip", "2026-01-01X18-21-49.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 1, 0, 0, 0, 0, ZoneOffset.ofHours(1)));

        verify(s3Service).deleteObjects(List.of("2026-01-01T18-21-49Z.zip"));
    }

    @Test
    void deleteAllBefore_ignoresSegmentZips() {
        when(s3Service.listObjects()).thenReturn(List.of("Segments_1.zip", "Segments_2026-01-01T00-00-00Z.zip", "2026-01-01T00-00-00Z.zip"));

        underTest.deleteAllBefore(OffsetDateTime.of(2026, 2, 1, 0, 0, 0, 0, ZoneOffset.UTC));

        verify(s3Service).deleteObjects(List.of("2026-01-01T00-00-00Z.zip"));
    }
}

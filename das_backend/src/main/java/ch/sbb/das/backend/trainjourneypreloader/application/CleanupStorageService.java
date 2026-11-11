package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.SegmentProfileStore.SEGMENT_PREFIX;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.FILENAME_FORMATTER;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.ZIP_FILE_ENDING;

import ch.sbb.das.backend.trainjourneypreloader.infrastructure.S3Service;
import java.time.OffsetDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Deletes the run zips (journeys and train characteristics) the devices no longer need. Segment zips are compacted by the {@link SegmentProfileStore}.
 */
@Slf4j
@Service
public class CleanupStorageService {

    private final S3Service s3Service;

    public CleanupStorageService(S3Service s3Service) {
        this.s3Service = s3Service;
    }

    void deleteAllBefore(OffsetDateTime cutoffDate) {
        List<String> keysToDelete = s3Service.listObjects().stream()
            .filter(k -> k != null && k.endsWith(ZIP_FILE_ENDING) && !k.contains(SEGMENT_PREFIX))
            .filter(k -> {
                try {
                    String base = k.substring(0, k.length() - ZIP_FILE_ENDING.length());
                    OffsetDateTime ts = OffsetDateTime.parse(base, FILENAME_FORMATTER);
                    return ts.isBefore(cutoffDate);
                } catch (DateTimeParseException e) {
                    log.warn("Unexpected zip file name while preload cleanup. name={} was not deleted", k);
                    return false;
                }
            }).toList();

        if (!keysToDelete.isEmpty()) {
            s3Service.deleteObjects(keysToDelete);
        }
    }
}

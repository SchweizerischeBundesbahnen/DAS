package ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.unit.DataSize;

/**
 * Rules of the segment profile store: when a segment profile is stale, when a segment zip is frozen and when the daily compaction runs.
 *
 * @param staleAfter        an SP no journey in the preload window referenced for this long is stale and evicted by the next compaction
 * @param rebuildStaleShare a full segment zip whose share of stale entries is over this is rebuilt by the daily compaction with its live entries only
 * @param openZipMaxAge     the open segment zip is frozen and a new one opened once it is older than this
 * @param packAfter         the daily compaction runs once the oldest frozen hourly segment zip is older than this
 * @param zipMaxBytes       a segment zip is full and closed once it has reached this size; the daily compaction folds every frozen zip that is not full
 */
@ConfigurationProperties(prefix = "trainjourneypreloader.segment-profiles")
public record SegmentProfileStoreProperties(Duration staleAfter, double rebuildStaleShare, Duration openZipMaxAge, Duration packAfter, DataSize zipMaxBytes) {

}

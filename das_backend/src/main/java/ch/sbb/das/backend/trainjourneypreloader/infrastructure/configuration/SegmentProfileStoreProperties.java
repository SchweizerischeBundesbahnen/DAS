package ch.sbb.das.backend.trainjourneypreloader.infrastructure.configuration;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.unit.DataSize;

/**
 * Rules of the segment profile store: when a segment profile is stale, when a segment zip is frozen and when frozen zips are rebuilt.
 *
 * @param staleAfter        an SP no journey in the preload window referenced for this long is stale and evicted by the next compaction
 * @param rebuildStaleShare a frozen segment zip whose share of stale entries is over this is rebuilt with its live entries only
 * @param openZipMaxAge     the open segment zip is frozen and a new one opened once it is older than this
 * @param packAfter         frozen hourly segment zips older than this are packed together
 * @param zipMaxBytes       a segment zip is closed once it has reached this size and the next entry opens the next zip
 */
@ConfigurationProperties(prefix = "trainjourneypreloader.segment-profiles")
public record SegmentProfileStoreProperties(Duration staleAfter, double rebuildStaleShare, Duration openZipMaxAge, Duration packAfter, DataSize zipMaxBytes) {

}

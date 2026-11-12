package ch.sbb.das.backend.trainjourneypreloader.application;

import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.FILENAME_FORMATTER;
import static ch.sbb.das.backend.trainjourneypreloader.application.StorageService.ZIP_FILE_ENDING;

import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.Optional;
import java.util.Set;

/**
 * Names of the segment zips in the preload bucket and of the SP entries inside them.
 * <p>
 * Hourly zips are {@code Segments_<timestamp>.zip}, packed zips {@code Segments_<timestamp>-packed.zip}, legacy zips {@code Segments_<n>.zip}. SP entries are
 * {@code sp/SP_<idVersion>.xml}.
 */
final class SegmentZipKeys {

    static final String SEGMENT_PREFIX = "Segments";

    private static final String KEY_PREFIX = SEGMENT_PREFIX + "_";
    private static final String PACKED_KEY_SUFFIX = "-packed";
    private static final String ENTRY_PREFIX = "sp/SP_";
    private static final String ENTRY_SUFFIX = ".xml";

    private SegmentZipKeys() {
    }

    static boolean isSegmentZip(String key) {
        return key.startsWith(KEY_PREFIX);
    }

    /** A key for a new hourly zip, named after now or after a later second than every existing hourly zip, so that it is the newest one. */
    static String newHourlyZipKey(Instant now, Set<String> zipKeys) {
        Instant stamp = now.truncatedTo(ChronoUnit.SECONDS);
        Instant newest = zipKeys.stream().flatMap(zipKey -> hourlyZipOpenedAt(zipKey).stream()).max(Comparator.naturalOrder()).orElse(Instant.MIN);
        return unusedZipKey(stamp.isAfter(newest) ? stamp : newest.plusSeconds(1), "", zipKeys);
    }

    /** A key for a new packed zip, named after now. */
    static String newPackedZipKey(Instant now, Set<String> zipKeys) {
        return unusedZipKey(now.truncatedTo(ChronoUnit.SECONDS), PACKED_KEY_SUFFIX, zipKeys);
    }

    /** The moment an hourly zip was opened; empty for packed and legacy zips. */
    static Optional<Instant> hourlyZipOpenedAt(String zipKey) {
        if (!zipKey.startsWith(KEY_PREFIX) || !zipKey.endsWith(ZIP_FILE_ENDING)) {
            return Optional.empty();
        }
        String stamp = zipKey.substring(KEY_PREFIX.length(), zipKey.length() - ZIP_FILE_ENDING.length());
        if (stamp.endsWith(PACKED_KEY_SUFFIX)) {
            return Optional.empty();
        }
        try {
            return Optional.of(OffsetDateTime.parse(stamp, FILENAME_FORMATTER).toInstant());
        } catch (DateTimeParseException _) {
            return Optional.empty();
        }
    }

    static String entryName(String idVersion) {
        return ENTRY_PREFIX + idVersion + ENTRY_SUFFIX;
    }

    static String idVersionOf(String entryName) {
        return entryName.substring(ENTRY_PREFIX.length(), entryName.length() - ENTRY_SUFFIX.length());
    }

    /** The key for the stamp, moved to a later second while a zip uses it already; the key is added to the used ones. */
    private static String unusedZipKey(Instant stamp, String suffix, Set<String> zipKeys) {
        Instant unused = stamp;
        String zipKey = zipKey(unused, suffix);
        while (zipKeys.contains(zipKey)) {
            unused = unused.plusSeconds(1);
            zipKey = zipKey(unused, suffix);
        }
        zipKeys.add(zipKey);
        return zipKey;
    }

    private static String zipKey(Instant stamp, String suffix) {
        return KEY_PREFIX + FILENAME_FORMATTER.format(stamp.atOffset(ZoneOffset.UTC)) + suffix + ZIP_FILE_ENDING;
    }
}

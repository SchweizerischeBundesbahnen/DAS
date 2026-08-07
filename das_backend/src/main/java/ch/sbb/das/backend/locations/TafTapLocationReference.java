package ch.sbb.das.backend.locations;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonCreator.Mode;
import com.fasterxml.jackson.annotation.JsonValue;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * TAF/TAP location reference (also called StopPoint).
 * <p>
 * Composed of a UIC country code and a location primary code (5 digits). Optionally carries a check digit (6th digit) when constructed from a full UIC code.
 * <p>
 * Equality is based on {@code countryCodeUic} and {@code primaryCode} only, so instances with and without check digit are considered equal for the same location.
 *
 * @see <a href="https://uic.org/support-activities/it/article/country-codes">UIC Country Codes</a>
 */
public final class TafTapLocationReference {

    private static final int MAX_PRIMARY_CODE = 99999;
    private static final int CHECK_DIGIT_DIVISOR = 10;
    private static final int FULL_UIC_CODE_FACTOR = 1_000_000;

    /**
     * UIC country code to ISO 3166-1 alpha-2 mapping.
     */
    private static final Map<Integer, String> UIC_TO_ISO = Map.<Integer, String>ofEntries(
        Map.entry(10, "FI"),
        Map.entry(20, "RU"),
        Map.entry(21, "BY"),
        Map.entry(22, "UA"),
        Map.entry(23, "MD"),
        Map.entry(24, "LT"),
        Map.entry(25, "LV"),
        Map.entry(26, "EE"),
        Map.entry(27, "KZ"),
        Map.entry(28, "GE"),
        Map.entry(29, "UZ"),
        Map.entry(30, "KP"),
        Map.entry(31, "MN"),
        Map.entry(32, "VN"),
        Map.entry(33, "CN"),
        Map.entry(34, "LA"),
        Map.entry(40, "CU"),
        Map.entry(41, "AL"),
        Map.entry(42, "JP"),
        Map.entry(44, "BA"),
        Map.entry(49, "BA"),
        Map.entry(50, "BA"),
        Map.entry(51, "PL"),
        Map.entry(52, "BG"),
        Map.entry(53, "RO"),
        Map.entry(54, "CZ"),
        Map.entry(55, "HU"),
        Map.entry(56, "SK"),
        Map.entry(57, "AZ"),
        Map.entry(58, "AM"),
        Map.entry(59, "KG"),
        Map.entry(60, "IE"),
        Map.entry(61, "KR"),
        Map.entry(62, "ME"),
        Map.entry(65, "MK"),
        Map.entry(66, "TJ"),
        Map.entry(67, "TM"),
        Map.entry(68, "AF"),
        Map.entry(70, "GB"),
        Map.entry(71, "ES"),
        Map.entry(72, "RS"),
        Map.entry(73, "GR"),
        Map.entry(74, "SE"),
        Map.entry(75, "TR"),
        Map.entry(76, "NO"),
        Map.entry(78, "HR"),
        Map.entry(79, "SI"),
        Map.entry(80, "DE"),
        Map.entry(81, "AT"),
        Map.entry(82, "LU"),
        Map.entry(83, "IT"),
        Map.entry(84, "NL"),
        Map.entry(85, "CH"),
        Map.entry(86, "DK"),
        Map.entry(87, "FR"),
        Map.entry(88, "BE"),
        Map.entry(89, "TZ"),
        Map.entry(90, "EG"),
        Map.entry(91, "TN"),
        Map.entry(92, "DZ"),
        Map.entry(93, "MA"),
        Map.entry(94, "PT"),
        Map.entry(95, "IL"),
        Map.entry(96, "IR"),
        Map.entry(97, "SY"),
        Map.entry(98, "LB"),
        Map.entry(99, "IQ")
    );

    /** Reverse lookup derived from UIC_TO_ISO. For ISO codes with multiple UIC codes (BA), uses the highest. */
    private static final Map<String, Integer> ISO_TO_UIC = UIC_TO_ISO.entrySet().stream()
        .collect(Collectors.toUnmodifiableMap(Map.Entry::getValue, Map.Entry::getKey, Math::max));

    private final int countryCodeUic;
    private final int primaryCode;
    private final Integer checkDigit;

    public TafTapLocationReference(int countryCodeUic, int primaryCode, Integer checkDigit) {
        if (UIC_TO_ISO.get(countryCodeUic) == null) {
            throw new IllegalArgumentException("Unknown UIC country code: " + countryCodeUic);
        }
        if (primaryCode < 0 || primaryCode > MAX_PRIMARY_CODE) {
            throw new IllegalArgumentException("primaryCode must be 0-99999, got: " + primaryCode);
        }
        this.countryCodeUic = countryCodeUic;
        this.primaryCode = primaryCode;
        this.checkDigit = checkDigit;
    }

    /**
     * Parse from the short format "CH52344" (ISO country code + 5-digit primary code). Check digit is not available in this format.
     */
    @JsonCreator(mode = Mode.DELEGATING)
    public static TafTapLocationReference of(String locationCode) {
        if (locationCode == null || locationCode.length() < 3) {
            throw new IllegalArgumentException("Invalid location code: " + locationCode);
        }
        String countryCodeIso = locationCode.substring(0, 2);
        Integer countryCodeUic = ISO_TO_UIC.get(countryCodeIso);
        if (countryCodeUic == null) {
            throw new IllegalArgumentException("Unknown ISO country code: " + countryCodeIso);
        }
        int primaryCode = Integer.parseInt(locationCode.substring(2));
        return new TafTapLocationReference(countryCodeUic, primaryCode, null);
    }

    /**
     * Create from a UIC code with checkDigit (e.g. 85523440).
     */
    public static TafTapLocationReference of(Integer uicCode) {
        if (uicCode == null) {
            throw new IllegalArgumentException("uicCode must not be null");
        }
        int countryCodeUic = uicCode / FULL_UIC_CODE_FACTOR;
        int primaryCodeWithCheckDigit = uicCode % FULL_UIC_CODE_FACTOR;
        int primaryCode = primaryCodeWithCheckDigit / CHECK_DIGIT_DIVISOR;
        int checkDigit = primaryCodeWithCheckDigit % CHECK_DIGIT_DIVISOR;
        return new TafTapLocationReference(countryCodeUic, primaryCode, checkDigit);
    }

    /**
     * Create from UIC country code and location code with check digit.
     */
    public static TafTapLocationReference of(Integer countryCodeUic, Integer primaryCodeWithCheckDigit) {
        return TafTapLocationReference.of(countryCodeUic * FULL_UIC_CODE_FACTOR + primaryCodeWithCheckDigit);
    }

    /** UIC country code (numeric, e.g. 85 for Switzerland). */
    public int countryCodeUic() {
        return countryCodeUic;
    }

    /** ISO 3166-1 alpha-2 country code (e.g. "CH"). */
    public String countryCodeIso() {
        String countryCodeIso = UIC_TO_ISO.get(countryCodeUic);
        if (countryCodeIso == null) {
            throw new IllegalStateException("No ISO mapping for UIC country code: " + countryCodeUic);
        }
        return countryCodeIso;
    }

    /** 5-digit location primary code without check digit. */
    public int primaryCode() {
        return primaryCode;
    }

    /**
     * 6-digit location code WITH check digit (primaryCode * 10 + checkDigit). Only available when constructed from a full UIC code.
     *
     * @throws IllegalStateException if check digit is not available
     */
    public int primaryCodeWithCheckDigit() {
        if (checkDigit == null) {
            throw new IllegalStateException("Check digit not available");
        }
        return primaryCode * CHECK_DIGIT_DIVISOR + checkDigit;
    }

    /**
     * Short format derived from SFERA: ISO country code + zero-padded 5-digit code without check digit (e.g. "CH52344").
     */
    @JsonValue
    public String locationCode() {
        return countryCodeIso() + String.format("%05d", primaryCode);
    }

    /**
     * Full UIC code (e.g. 85523440). Requires check digit to be present.
     */
    public int uicCode() {
        return countryCodeUic * FULL_UIC_CODE_FACTOR + primaryCodeWithCheckDigit();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        TafTapLocationReference that = (TafTapLocationReference) o;
        return countryCodeUic == that.countryCodeUic && primaryCode == that.primaryCode;
    }

    @Override
    public int hashCode() {
        return Objects.hash(countryCodeUic, primaryCode);
    }

    @Override
    public String toString() {
        return locationCode();
    }
}

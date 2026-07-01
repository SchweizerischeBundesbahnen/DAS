package ch.sbb.das.backend.companies;

import com.fasterxml.jackson.annotation.JsonValue;
import java.util.regex.Pattern;
import lombok.NonNull;

/**
 * 4-character RICS company code identifying an RU.
 * <p>
 * Relates to teltsi_CompanyCode (according to SFERA). Format: exactly 4 upper-case alphanumeric characters, e.g. {@code "2185"}.
 * <p>
 * JSON representation is a plain string.
 */
public record CompanyCode(@JsonValue @NonNull String value) {

    public static final String DESCRIPTION = "Relates to teltsi_CompanyCode (according to SFERA a [RICS-code](https://uic.org/support-activities/it/rics)).";

    private static final Pattern COMPANY_CODE_PATTERN = Pattern.compile("[0-9A-Z]{4}");

    public CompanyCode {
        if (!COMPANY_CODE_PATTERN.matcher(value).matches()) {
            throw new IllegalArgumentException("CompanyCode must match [0-9A-Z]{4}");
        }
    }
}

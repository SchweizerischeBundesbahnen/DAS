package ch.sbb.das.backend.restapi.e2etest.helper;

import java.util.List;
import java.util.Locale;
import lombok.experimental.UtilityClass;

@UtilityClass
public class ServiceDoc {

    // DO NOT use in @Schema(allowableValues=...) but consider ApiParametersDefault.ParamAcceptLanguage
    public static final List<Locale> HEADER_ACCEPT_LANGUAGE_VALUES = List.of(Locale.GERMAN, Locale.FRENCH, Locale.ITALIAN, Locale.ENGLISH);
    /**
     * RequestId for all E2E-Tests (make it distinguishable from real production requests).
     */
    public static final String REQUEST_ID_VALUE_E2E_TEST = "e2eTest";
    public static final String HEADER_CONTENT_LANGUAGE_ERROR_DETAIL_DEFAULT = "en";
    /**
     * Provoke tag for false positives.
     */
    public static final String TEST_MARKER_BAD = "BAD_";
}

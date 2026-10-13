package ch.sbb.das.backend.common;

public final class ApiParametersDefault {

    /**
     * devOps relevant header:
     * <ul>
     *     <li>Instana-Tracing among a chane of Instana based Applications is maintained by introspection intrinsically.</li>
     *     <li>Splunk logging</li>
     * </ul>
     * <p>
     *
     * @see <a href="https://www.instana.com/docs/ecosystem/opentelemetry/">OpenTelemtry</a>
     * @see <a href="https://confluence.sbb.ch/display/MON/Instana+-+HTTP+Header+Whitelist">Request-ID</a>
     */
    public static final String HEADER_REQUEST_ID = "Request-ID";

    private ApiParametersDefault() {
    }
}

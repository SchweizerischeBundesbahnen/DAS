package ch.sbb.das.backend.restapi.monitoring;

public interface MonitoringConstants {

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
    String HEADER_REQUEST_ID = "Request-ID";
}

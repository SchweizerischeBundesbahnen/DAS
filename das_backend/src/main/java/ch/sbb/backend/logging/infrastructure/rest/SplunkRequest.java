package ch.sbb.backend.logging.infrastructure.rest;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.OffsetDateTime;
import java.util.Map;

@JsonInclude(JsonInclude.Include.NON_NULL)
record SplunkRequest(
    String event,
    Map<String, String> fields,
    String host,
    String index,
    String source,
    OffsetDateTime time,
    String sourcetype
) {

    SplunkRequest(String event, Map<String, String> fields, String source, OffsetDateTime time) {
        this(event, fields, null, null, source, time, null);
    }
}

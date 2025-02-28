package ch.sbb.backend.logging.infrastructure.rest

import com.fasterxml.jackson.annotation.JsonInclude
import java.time.OffsetDateTime

data class SplunkRequest(
    val event: String,
    val fields: Map<String, String>,
    @JsonInclude(JsonInclude.Include.NON_NULL)
    val host: String? = null,
    @JsonInclude(JsonInclude.Include.NON_NULL)
    val index: String? = null,
    val source: String,
    val time: OffsetDateTime,
    @JsonInclude(JsonInclude.Include.NON_NULL)
    val sourcetype: String? = null
)

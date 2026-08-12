package ch.sbb.das.backend.cargo.infrastructure.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public record TransportPaperLinkResponse(
    String version,
    String downloadUrl
) {

}

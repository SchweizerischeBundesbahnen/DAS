package ch.sbb.das.backend.cargo.api.v1.model;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Link to a transport paper (Beförderungspapier) with type information indicating how the client should handle the URL.")
public record TransportPaperLink(
    @Schema(description = "URL to the transport paper resource.", requiredMode = Schema.RequiredMode.REQUIRED)
    String url,

    @Schema(description = "Type of the transport paper link, indicating how the client should handle it.", requiredMode = Schema.RequiredMode.REQUIRED)
    TransportPaperLinkType type
) {

    public enum TransportPaperLinkType {
        @Schema(description = "A relative URL to this backend that will redirect to the actual PDF download.")
        PDF_REDIRECT,

        @Schema(description = "A direct URL to a webapp or app link that can be opened directly by the client.")
        URL
    }
}

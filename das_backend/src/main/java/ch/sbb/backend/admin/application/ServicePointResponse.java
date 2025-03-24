package ch.sbb.backend.admin.application;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "ServicePoint")
public record ServicePointResponse(
    @Schema(
        description = "UIC-Code, combination of uicCountryCode and numberShort. Length: 7",
        example = "8518771"
    )
    Integer uic,

    @Schema(
        description = "Official designation of a location",
        example = "Biel/Bienne Bözingenfeld/Champ"
    )
    String designation,

    @Schema(
        description = "Location abbreviation",
        example = "BIBD"
    )
    String abbreviation
) {

}

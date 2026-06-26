package ch.sbb.das.backend.indications.internal.model;

import ch.sbb.das.backend.locations.TafTapLocationReference;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Schema;
import java.util.List;

@Schema(description = "A requested TAF/TAP location reference enriched with matched RU indication contents in a single resolved language.")
public record RuIndicationMatch(
    @Schema(requiredMode = Schema.RequiredMode.REQUIRED)
    TafTapLocationReference tafTapLocationReference,
    @ArraySchema(arraySchema = @Schema(requiredMode = Schema.RequiredMode.REQUIRED))
    List<RuIndicationEntry> ruIndicationContents
) {

}

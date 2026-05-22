package ch.sbb.das.backend.admin.application.ruindications.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

@Schema(description = "Train number filter expression. Examples: '300' or '300-400'.")
public record TrainNumberFilterRequest(
    @Schema(description = "Train number expression. Allowed formats: single number (e.g. 300) or range (e.g. 300-400).", requiredMode = Schema.RequiredMode.REQUIRED, example = "162-180")
    @NotBlank
    @Pattern(regexp = "^\\d+(?:-\\d+)?$", message = "expression must match '<number>' or '<from>-<to>'")
    String expression,
    @Schema(description = "Parity filter applied to the expression.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    TrainNumberParity parity
) {

    @JsonIgnore
    @Schema(hidden = true)
    @AssertTrue(message = "range expression must have from <= to")
    public boolean isRangeValid() {
        if (expression == null || !expression.contains("-")) {
            return true;
        }
        String[] parts = expression.split("-", 2);
        int from = Integer.parseInt(parts[0]);
        int to = Integer.parseInt(parts[1]);
        return from <= to;
    }
}


package ch.sbb.das.backend.indications.internal.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

@Schema(description = "Train number filter expression. Examples: '300' or '300-400'.")
public record OperationalTrainNumberFilter(
    @Schema(description = "Train number expression. Allowed formats: single number (e.g. 300) or range (e.g. 300-400).", requiredMode = Schema.RequiredMode.REQUIRED, example = "162-180")
    @NotBlank
    @Pattern(regexp = EXPRESSION_PATTERN, message = "expression must match '<number>' or '<from>" + RANGE_SEPARATOR + "<to>'")
    String expression,
    @Schema(description = "Parity filter applied to the expression.", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    TrainNumberParity parity
) {

    private static final String RANGE_SEPARATOR = "-";
    private static final String EXPRESSION_PATTERN = "^\\d+(?:" + RANGE_SEPARATOR + "\\d+)?$";

    @JsonIgnore
    @Schema(hidden = true)
    @AssertTrue(message = "range expression must have from <= to")
    public boolean isRangeValid() {
        if (expression == null || !expression.contains(RANGE_SEPARATOR) || !expression.matches(EXPRESSION_PATTERN)) {
            return true;
        }
        String[] parts = expression.split(RANGE_SEPARATOR, 2);
        int from = Integer.parseInt(parts[0]);
        int to = Integer.parseInt(parts[1]);
        return from <= to;
    }
}

package ch.sbb.das.backend.admin.application.notices.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Set;

@Schema(description = "Notice validity period. A single day is represented by from == to.")
public record NoticePeriod(
    @Schema(description = "Start date (inclusive).", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    LocalDate validFrom,
    @Schema(description = "End date (inclusive).", requiredMode = Schema.RequiredMode.REQUIRED)
    @NotNull
    LocalDate validTo,
    @Schema(description = "Weekdays for recurring date ranges. Must be empty for single-day periods. Also matched by special holidays.")
    Set<DayOfWeek> weekdays
) {

    @JsonIgnore
    @Schema(hidden = true)
    @AssertTrue(message = "from must be before or equal to to")
    public boolean isDateRangeValid() {
        if (validFrom == null || validTo == null) {
            return true;
        }
        return !validFrom.isAfter(validTo);
    }

    @JsonIgnore
    @Schema(hidden = true)
    @AssertTrue(message = "weekdays must be empty for single-day periods")
    public boolean isWeekdaySelectionValid() {
        if (validFrom == null || validTo == null) {
            return true;
        }
        boolean singleDay = validFrom.isEqual(validTo);
        boolean hasWeekdays = weekdays != null && !weekdays.isEmpty();
        return !singleDay || !hasWeekdays;
    }
}


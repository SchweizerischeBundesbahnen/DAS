package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.companies.Company;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

@Schema(description = "A company matched from a train identification lookup.")
public record CompanyMatch(
    @Schema(description = "The company operating the train.", requiredMode = Schema.RequiredMode.REQUIRED)
    Company company,
    @Schema(description = "The start date of the train journey.", requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDate startDate
) {

}

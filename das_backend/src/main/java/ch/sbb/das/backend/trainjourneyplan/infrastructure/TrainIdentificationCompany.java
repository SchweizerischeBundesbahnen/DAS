package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.companies.Company;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

@Schema(description = "A company associated with a train identification on a specific start date.")
public record TrainIdentificationCompany(
    @Schema(description = "The company operating the train.", requiredMode = Schema.RequiredMode.REQUIRED)
    Company company,
    @Schema(description = "The operational start date of the train journey.", requiredMode = Schema.RequiredMode.REQUIRED)
    LocalDate startDate
) {

}

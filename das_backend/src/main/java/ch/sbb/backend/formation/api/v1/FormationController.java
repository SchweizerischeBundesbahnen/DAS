package ch.sbb.backend.formation.api.v1;

import ch.sbb.backend.ApiDocumentation;
import ch.sbb.backend.common.SFERA;
import ch.sbb.backend.common.TelTsi;
import ch.sbb.backend.formation.api.v1.model.FormationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Formations", description = "API for Cargo train formations.")
public class FormationController {

    public static final String OPERATIONAL_TRAIN_NUMBER_DESCRIPTION = "Relates to `teltsi_OperationalTrainNumber` (according to SFERA). In CH unique on a specific `operationalDay`.";
    public static final String OPERATIONAL_DAY_DESCRIPTION = "Operational day (underlying journey-planner specific, be aware of confusion with stop-times after midnight within a journey the day before).";
    public static final String COMPANY_DESCRIPTION = "Relates to teltsi_CompanyCode (according to SFERA resp. RICS-code).";
    private static final String PATH_SEGMENT_FORMATIONS = "/formations";
    private static final String API_FORMATIONS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_FORMATIONS;

    // todo: cacheable
    // todo: error API responses
    @Operation(summary = "Get formation by train identification")
    @ApiResponse(responseCode = "200", description = "Formation found")
    @GetMapping(path = API_FORMATIONS, produces = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity<FormationResponse> getFormation(
        @Parameter(description = OPERATIONAL_TRAIN_NUMBER_DESCRIPTION, required = true)
        @SFERA @TelTsi @RequestParam @NotBlank String operationalTrainNumber,

        @Parameter(description = OPERATIONAL_DAY_DESCRIPTION, required = true)
        @SFERA(nsp = true) @RequestParam @NotNull LocalDate operationalDay,

        @Parameter(description = COMPANY_DESCRIPTION)
        @SFERA @TelTsi @RequestParam @Pattern(regexp = "\\d{4}") String company) {
        // todo: check params and implement
        return ResponseEntity.status(HttpStatus.NOT_IMPLEMENTED).build();
    }
}

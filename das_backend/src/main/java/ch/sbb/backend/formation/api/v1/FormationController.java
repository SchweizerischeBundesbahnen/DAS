package ch.sbb.backend.formation.api.v1;

import ch.sbb.backend.ApiDocumentation;
import ch.sbb.backend.formation.api.v1.model.FormationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Formations", description = "API for train formations")
public class FormationController {

    private static final String PATH_SEGMENT_FORMATIONS = "/formations";
    private static final String API_FORMATIONS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_FORMATIONS;

    // todo: cacheable
    @Operation(summary = "Get formation by train identification")
    @ApiResponse(responseCode = "200", description = "Formation found")
    @GetMapping(path = API_FORMATIONS, produces = MediaType.APPLICATION_JSON_VALUE)
    ResponseEntity<FormationResponse> getFormation(
        @Parameter(description = "Relates to teltsi_OperationalTrainNumber (according to SFERA).")
        @RequestParam @NotBlank String operationalTrainNumber,

        @Parameter(description = "Operational day.")
        @RequestParam @NotNull LocalDate operationalDay,

        @Parameter(description = "Relates to teltsi_CompanyCode (according to SFERA).")
        @RequestParam @Pattern(regexp = "\\d{4}") String company) {
        return ResponseEntity.ok(FormationResponse.builder().build());
    }
}

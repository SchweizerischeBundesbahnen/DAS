package ch.sbb.backend.formation.api.v1;

import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiParametersDefault;
import ch.sbb.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.backend.common.ResponseEntityFactory;
import ch.sbb.backend.common.model.response.ApiErrorResponses;
import ch.sbb.backend.common.model.response.Problem;
import ch.sbb.backend.common.model.response.Response;
import ch.sbb.backend.common.standards.SFERA;
import ch.sbb.backend.common.standards.TelTsi;
import ch.sbb.backend.formation.api.v1.model.Formation;
import ch.sbb.backend.formation.api.v1.model.FormationResponse;
import ch.sbb.backend.formation.application.FormationService;
import ch.sbb.backend.formation.infrastructure.model.TrainFormationRunEntity;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.headers.Header;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import java.time.LocalDate;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.CollectionUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Formations", description = "API for Cargo train formations.")
public class FormationController {

    public static final String OPERATIONAL_TRAIN_NUMBER_DESCRIPTION = "Relates to `teltsi_OperationalTrainNumber` (according to SFERA). In CH unique on a specific `operationalDay`.";
    public static final String OPERATIONAL_DAY_DESCRIPTION = "Operational day (underlying journey-planner specific, be aware of confusion with stop-times after midnight within a journey the day before).";
    public static final String COMPANY_DESCRIPTION = "Relates to teltsi_CompanyCode (according to SFERA resp. RICS-code).";
    private static final String PATH_SEGMENT_FORMATIONS = "/formations";
    public static final String API_FORMATIONS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_FORMATIONS;

    private final FormationService formationService;

    public FormationController(FormationService formationService) {
        this.formationService = formationService;
    }

    @Operation(summary = "Get formation by train identification.")
    @ApiResponse(responseCode = "200", description = "Formation found", headers = {
        @Header(name = ApiDocumentation.HEADER_CACHE_CONTROL, description = ApiDocumentation.HEADER_CACHE_CONTROL_RESPONSE_DESCRIPTION,
            schema = @Schema(type = "string")),
        @Header(name = ApiDocumentation.HEADER_CACHE_ETAG, description = ApiDocumentation.HEADER_CACHE_ETAG_RESPONSE_DESCRIPTION,
            schema = @Schema(type = "string", example = ApiDocumentation.SAMPLE_CACHE_ETAG))
    }, content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = FormationResponse.class)))
    @ApiResponse(responseCode = "304", description = ApiDocumentation.STATUS_304, content = @Content /* actually empty body/content */)
    @ApiResponse(responseCode = "404", description = ApiDocumentation.STATUS_404,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = Problem.class)))
    @ApiErrorResponses
    @GetMapping(path = API_FORMATIONS)
    @Parameter(name = HttpHeaders.IF_NONE_MATCH, schema = @Schema(type = "string", example = ApiDocumentation.SAMPLE_CACHE_ETAG), description = ApiDocumentation.HEADER_CACHE_IF_NONE_MATCH_DESCRIPTION, in = ParameterIn.HEADER)
    ResponseEntity<? extends Response> getFormations(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,

        @Parameter(description = OPERATIONAL_TRAIN_NUMBER_DESCRIPTION, required = true)
        @SFERA @TelTsi @RequestParam @NotBlank String operationalTrainNumber,

        @Parameter(description = OPERATIONAL_DAY_DESCRIPTION, required = true, example = "2026-01-22")
        @SFERA(nsp = true) @RequestParam @NotNull LocalDate operationalDay,

        @Parameter(description = COMPANY_DESCRIPTION, example = "1033")
        @SFERA @TelTsi @RequestParam @Pattern(regexp = "\\d{4}") String company) {

        final List<TrainFormationRunEntity> entities = formationService.findByTrainIdentifier(operationalTrainNumber, operationalDay, company);
        if (CollectionUtils.isEmpty(entities)) {
            //TODO hardoded: replace by RequestContext
            String instance = API_FORMATIONS + "/" + operationalTrainNumber + "/" + operationalDay + "/" + company;
            return ResponseEntityFactory.createNotFoundResponse(requestId, instance);
        }

        final HttpHeaders headers = ResponseEntityFactory.createOkHeaders(null, requestId);
        headers.add(HttpHeaders.CACHE_CONTROL, "private");
        return ResponseEntityFactory.createOkResponse(
            headers,
            new FormationResponse(List.of(Formation.from(entities)))
        );
    }
}

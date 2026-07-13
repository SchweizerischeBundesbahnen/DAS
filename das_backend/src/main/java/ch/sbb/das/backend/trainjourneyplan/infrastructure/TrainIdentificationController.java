package ch.sbb.das.backend.trainjourneyplan.infrastructure;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.trainjourneyplan.TrainIdentificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.time.LocalDate;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "Train Identifications", description = "API for resolving companies from train identifications.")
public class TrainIdentificationController {

    private static final String PATH_SEGMENT_TRAIN_IDENTIFICATIONS = "/train-identifications";
    public static final String API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_TRAIN_IDENTIFICATIONS + "/companies";

    private final TrainIdentificationService trainIdentificationService;

    @GetMapping(API_DRIVER_TRAIN_IDENTIFICATION_COMPANIES)
    @Operation(summary = "Resolve companies by train identification.", description = "Returns companies associated with a train identification for given operational start dates and train number.")
    @ApiResponse(responseCode = "200", description = "Companies found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = TrainIdentificationCompanyResponse.class)))
    @ApiResponse(responseCode = "404", description = "No train identification found for the given parameters.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getCompaniesByTrainIdentification(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @Parameter(description = "The start date. Can be specified multiple times.", required = true, example = "2026-07-10") @RequestParam @NotEmpty List<LocalDate> startDate,
        @Parameter(description = "The operational train number.", required = true) @RequestParam @NotBlank String operationalTrainNumber) {

        List<TrainIdentificationCompany> companies = trainIdentificationService.findCompaniesByStartDatesAndTrainNumber(startDate, operationalTrainNumber);

        if (companies.isEmpty()) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new TrainIdentificationCompanyResponse(companies), requestId);
    }
}

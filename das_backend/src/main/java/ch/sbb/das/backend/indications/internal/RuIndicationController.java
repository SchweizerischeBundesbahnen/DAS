package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.DeleteByIdsRequest;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.indications.internal.model.RuIndication;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatch;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatchResponse;
import ch.sbb.das.backend.indications.internal.model.RuIndicationMatchesRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationRequest;
import ch.sbb.das.backend.indications.internal.model.RuIndicationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "RU indications", description = "API for RU indications.")
public class RuIndicationController {

    static final String PATH_SEGMENT_RU_INDICATIONS = "/ruindications";
    public static final String API_RU_INDICATIONS = ApiDocumentation.ADMIN_URI + PATH_SEGMENT_RU_INDICATIONS;
    static final String API_RU_INDICATIONS_ID = API_RU_INDICATIONS + "/{id}";
    public static final String API_DRIVER_RU_INDICATION_MATCHES = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_RU_INDICATIONS + "/matches";
    private final RuIndicationServiceImpl ruIndicationService;
    private final RuIndicationMatchServiceImpl ruIndicationMatchService;

    @GetMapping(API_RU_INDICATIONS)
    @Operation(summary = "Get all RU indications.", description = "Returns all RU indications visible for the authorized companies.")
    @ApiResponse(responseCode = "200", description = "RU indications found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllRuIndications(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<RuIndication> ruIndications = ruIndicationService.getAll();
        return ResponseEntityFactory.createOkResponse(new RuIndicationResponse(ruIndications), requestId);
    }

    @GetMapping(API_RU_INDICATIONS_ID)
    @Operation(summary = "Get RU indication by id.", description = "Returns a single RU indication by its id.")
    @ApiResponse(responseCode = "200", description = "RU indication found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU indication not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getRuIndicationById(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        RuIndication ruIndication = ruIndicationService.getById(id);
        if (ruIndication == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new RuIndicationResponse(ruIndication), requestId);
    }

    @PostMapping(API_RU_INDICATIONS)
    @Operation(summary = "Create new RU indication.", description = "Creates a new RU indication entry.")
    @ApiResponse(responseCode = "201", description = "RU indication created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<RuIndicationResponse> createRuIndication(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid RuIndicationRequest createRequest) {
        RuIndication createdRuIndication = ruIndicationService.create(createRequest);
        return ResponseEntityFactory.createCreatedResponse(new RuIndicationResponse(createdRuIndication), requestId);
    }

    @PostMapping(API_DRIVER_RU_INDICATION_MATCHES)
    @Operation(summary = ApiDocumentation.HINT_GET_BY_POST + " Get RU indication matches.",
        description =
            "Filters RU indications for one company, train number and start date, and returns requested TAF/TAP location references with their matched RU indication contents in one resolved language. "
                + "If the request train number is a shadow train, train filtering also checks the corresponding original train number (-70'000). Date filtering considers special holiday schedule mapping.")
    @ApiResponse(responseCode = "200", description = "RU indication matches found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationMatchResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> findRuIndicationMatches(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, required = false) String acceptLanguage,
        @RequestBody @Valid RuIndicationMatchesRequest filterRequest) {
        List<RuIndicationMatch> ruIndicationMatches = ruIndicationMatchService.findMatches(filterRequest, acceptLanguage);
        return ResponseEntityFactory.createOkResponse(new RuIndicationMatchResponse(ruIndicationMatches), requestId);
    }

    @PutMapping(API_RU_INDICATIONS_ID)
    @Operation(summary = "Update RU indication by id.", description = "Updates a single RU indication by its id.")
    @ApiResponse(responseCode = "200", description = "RU indication updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU indication not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateRuIndication(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid RuIndicationRequest updateRequest,
        @PathVariable Integer id) {
        RuIndication updatedRuIndication = ruIndicationService.update(id, updateRequest);
        if (updatedRuIndication == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new RuIndicationResponse(updatedRuIndication), requestId);
    }

    @DeleteMapping(API_RU_INDICATIONS)
    @Operation(summary = "Delete RU indications by ids.", description = "Deletes multiple RU indications in a single request.")
    @ApiResponse(responseCode = "204", description = "RU indications deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteRuIndicationByIds(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid DeleteByIdsRequest deleteRequest) {
        ruIndicationService.delete(deleteRequest.ids());
        return ResponseEntity.noContent().build();
    }
}

package ch.sbb.das.backend.externallinks.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.DeleteByIdsRequest;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.companies.CompanyCode;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "ExternalLinks", description = "API for external links.")
@RequiredArgsConstructor
public class ExternalLinkController {

    static final String PATH_SEGMEMT_EXTERNAL_LINKS = "/external-links";
    public static final String API_ADMIN_EXTERNAL_LINKS = ApiDocumentation.ADMIN_URI + PATH_SEGMEMT_EXTERNAL_LINKS;
    static final String API_EXTERNAL_LINKS_ID = API_ADMIN_EXTERNAL_LINKS + "/{id}";
    public static final String API_DRIVER_EXTERNAL_LINKS = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMEMT_EXTERNAL_LINKS;
    private final ExternalLinkServiceImpl externalLinkService;

    @GetMapping(API_ADMIN_EXTERNAL_LINKS)
    @Operation(
        summary = "Get external links.",
        description = "Returns all external links visible for the authorized companies."
    )
    @ApiResponse(responseCode = "200", description = "External links found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ExternalLinkResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllExternalLinks(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId) {
        return ResponseEntityFactory.createOkResponse(new ExternalLinkResponse(externalLinkService.getAll()), requestId);
    }

    @GetMapping(API_DRIVER_EXTERNAL_LINKS)
    @Operation(
        summary = "Get external links filtered by companies.",
        description = "Returns all external links filterd by companies."
    )
    @ApiResponse(responseCode = "200", description = "External links found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ExternalLinkResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllExternalLinksByCompanies(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId,
        @Parameter(description = CompanyCode.DESCRIPTION, example = "1033")
        @RequestParam
        Set<CompanyCode> companies) {
        return ResponseEntityFactory.createOkResponse(new ExternalLinkResponse(externalLinkService.getAllByCompanies(companies)), requestId);
    }

    @GetMapping(API_EXTERNAL_LINKS_ID)
    @Operation(summary = "Get external link by id.", description = "Returns a single external link by its id.")
    @ApiResponse(responseCode = "200", description = "External link found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ExternalLinkResponse.class)))
    @ApiResponse(responseCode = "404", description = "External link not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getExternalLinkById(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId,
        @PathVariable
        Integer id) {
        ExternalLink externalLink = externalLinkService.getById(id);
        if (externalLink == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new ExternalLinkResponse(externalLink), requestId);
    }

    @PostMapping(API_ADMIN_EXTERNAL_LINKS)
    @Operation(summary = "Create new external link.", description = "Creates a new external link entry.")
    @ApiResponse(responseCode = "201", description = "External link created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ExternalLinkResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<ExternalLinkResponse> createExternalLink(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId,
        @RequestBody @Valid
        ExternalLinkRequest createRequest) {
        return ResponseEntityFactory.createCreatedResponse(new ExternalLinkResponse(externalLinkService.create(createRequest)), requestId);
    }

    @PutMapping(API_EXTERNAL_LINKS_ID)
    @Operation(summary = "Update external link by id.", description = "Updates a single external link by its id.")
    @ApiResponse(responseCode = "200", description = "External link updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = ExternalLinkResponse.class)))
    @ApiResponse(responseCode = "404", description = "External link not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateExternalLink(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId,
        @RequestBody @Valid
        ExternalLinkRequest updateRequest,
        @PathVariable
        Integer id) {
        ExternalLink externalLink = externalLinkService.update(id, updateRequest);
        if (externalLink == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new ExternalLinkResponse(externalLink), requestId);
    }

    @DeleteMapping(API_ADMIN_EXTERNAL_LINKS)
    @Operation(summary = "Delete external links by ids.", description = "Delete multiple external links in a single request.")
    @ApiResponse(responseCode = "204", description = "External links deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteExternalLinkByIds(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false)
        String requestId,
        @RequestBody @Valid
        DeleteByIdsRequest deleteRequest) {
        externalLinkService.deleteAllById(deleteRequest.ids());
        return ResponseEntityFactory.createNoContentResponse(requestId);
    }
}

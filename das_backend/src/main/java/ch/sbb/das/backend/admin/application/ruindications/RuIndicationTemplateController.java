package ch.sbb.das.backend.admin.application.ruindications;

import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplate;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplateRequest;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplateResponse;
import ch.sbb.das.backend.admin.application.ruindications.model.RuIndicationTemplatesResponse;
import ch.sbb.das.backend.admin.domain.ruindications.RuIndicationTemplateService;
import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.DeleteByIdsRequest;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
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
@Tag(name = "RU indication templates", description = "API for RU indication templates.")
public class RuIndicationTemplateController {

    static final String PATH_SEGMENT_RU_INDICATION_TEMPLATES = "/ruindication-templates";
    public static final String API_RU_INDICATION_TEMPLATES = ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_RU_INDICATION_TEMPLATES;
    static final String API_RU_INDICATION_TEMPLATES_ID = API_RU_INDICATION_TEMPLATES + "/{id}";

    private final RuIndicationTemplateService ruIndicationTemplateService;

    public RuIndicationTemplateController(RuIndicationTemplateService ruIndicationTemplateService) {
        this.ruIndicationTemplateService = ruIndicationTemplateService;
    }

    @GetMapping(API_RU_INDICATION_TEMPLATES)
    @Operation(summary = "Get all RU indication templates.", description = "Returns all RU indication templates.")
    @ApiResponse(responseCode = "200", description = "RU indication templates found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationTemplatesResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllRuIndicationTemplates(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<RuIndicationTemplate> ruIndicationTemplates = ruIndicationTemplateService.getAll();
        return ResponseEntityFactory.createOkResponse(new RuIndicationTemplatesResponse(ruIndicationTemplates), requestId);
    }

    @GetMapping(API_RU_INDICATION_TEMPLATES_ID)
    @Operation(summary = "Get RU indication template by id.", description = "Returns a single RU indication template by its id.")
    @ApiResponse(responseCode = "200", description = "RU indication template found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationTemplateResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU indication template not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getRuIndicationTemplateById(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        RuIndicationTemplate ruIndicationTemplate = ruIndicationTemplateService.getById(id);
        if (ruIndicationTemplate == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new RuIndicationTemplateResponse(ruIndicationTemplate), requestId);
    }

    @PostMapping(API_RU_INDICATION_TEMPLATES)
    @Operation(summary = "Create new RU indication template.", description = "Creates a new RU indication template entry.")
    @ApiResponse(responseCode = "201", description = "RU indication template created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationTemplateResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<RuIndicationTemplateResponse> createRuIndicationTemplate(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid RuIndicationTemplateRequest createRequest) {
        RuIndicationTemplate createdRuIndicationTemplate = ruIndicationTemplateService.create(createRequest);
        return ResponseEntityFactory.createCreatedResponse(new RuIndicationTemplateResponse(createdRuIndicationTemplate), requestId);
    }

    @PutMapping(API_RU_INDICATION_TEMPLATES_ID)
    @Operation(summary = "Update RU indication template by id.", description = "Updates a single RU indication template by its id.")
    @ApiResponse(responseCode = "200", description = "RU indication template updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = RuIndicationTemplateResponse.class)))
    @ApiResponse(responseCode = "404", description = "RU indication template not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateRuIndicationTemplate(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid RuIndicationTemplateRequest updateRequest,
        @PathVariable Integer id) {
        RuIndicationTemplate ruIndicationTemplate = ruIndicationTemplateService.update(id, updateRequest);
        if (ruIndicationTemplate == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new RuIndicationTemplatesResponse(List.of(ruIndicationTemplate)), requestId);
    }

    @DeleteMapping(API_RU_INDICATION_TEMPLATES)
    @Operation(summary = "Delete RU indication templates by ids.", description = "Delete multiple RU indication templates in a single request.")
    @ApiResponse(responseCode = "204", description = "RU indication templates deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteRuIndicationTemplateByIds(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid DeleteByIdsRequest deleteRequest) {
        ruIndicationTemplateService.delete(deleteRequest.ids());
        return ResponseEntity.noContent().build();
    }
}

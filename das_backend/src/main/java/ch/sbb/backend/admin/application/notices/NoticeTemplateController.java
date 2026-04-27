package ch.sbb.backend.admin.application.notices;

import ch.sbb.backend.admin.application.notices.model.NoticeTemplate;
import ch.sbb.backend.admin.application.notices.model.NoticeTemplateRequest;
import ch.sbb.backend.admin.application.notices.model.NoticeTemplateResponse;
import ch.sbb.backend.admin.application.notices.model.NoticeTemplatesResponse;
import ch.sbb.backend.admin.domain.notices.NoticeTemplateService;
import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiErrorResponses;
import ch.sbb.backend.common.ApiParametersDefault;
import ch.sbb.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.backend.common.Response;
import ch.sbb.backend.common.ResponseEntityFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
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
@Tag(name = "NoticeTemplates", description = "API for notice templates.")
public class NoticeTemplateController {

    static final String PATH_SEGMENT_NOTICES_TEMPLATES = "/notice-templates";
    public static final String API_NOTICE_TEMPLATES = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_NOTICES_TEMPLATES;
    static final String API_NOTICE_TEMPLATES_ID = API_NOTICE_TEMPLATES + "/{id}";

    private final NoticeTemplateService noticeTemplateService;

    public NoticeTemplateController(NoticeTemplateService noticeTemplateService) {
        this.noticeTemplateService = noticeTemplateService;
    }

    @GetMapping(API_NOTICE_TEMPLATES)
    @Operation(summary = "Get all notice templates.", description = "Returns all notice templates.")
    @ApiResponse(responseCode = "200", description = "Notice templates found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeTemplatesResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<NoticeTemplate> noticeTemplates = noticeTemplateService.getAll();
        return ResponseEntityFactory.createOkResponse(new NoticeTemplatesResponse(noticeTemplates), null, requestId);
    }

    @GetMapping(API_NOTICE_TEMPLATES_ID)
    @Operation(summary = "Get notice template by id.", description = "Returns a single notice template by its id.")
    @ApiResponse(responseCode = "200", description = "Notice template found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeTemplateResponse.class)))
    @ApiResponse(responseCode = "404", description = "Notice template not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        NoticeTemplate noticeTemplate = noticeTemplateService.getById(id);
        if (noticeTemplate == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new NoticeTemplateResponse(noticeTemplate), null, requestId);
    }

    @PostMapping(API_NOTICE_TEMPLATES)
    @Operation(summary = "Create new notice template.", description = "Creates a new notice template entry.")
    @ApiResponse(responseCode = "201", description = "Notice template created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeTemplateResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<NoticeTemplateResponse> create(@RequestBody @Valid NoticeTemplateRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        NoticeTemplate createdNoticeTemplate = noticeTemplateService.create(createRequest);
        HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        return new ResponseEntity<>(new NoticeTemplateResponse(createdNoticeTemplate), headers, HttpStatus.CREATED);
    }

    @PutMapping(API_NOTICE_TEMPLATES_ID)
    @Operation(summary = "Update notice template by id.", description = "Updates a single notice template by its id.")
    @ApiResponse(responseCode = "200", description = "Notice template updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeTemplateResponse.class)))
    @ApiResponse(responseCode = "404", description = "Notice template not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> update(@PathVariable Integer id, @RequestBody @Valid NoticeTemplateRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        NoticeTemplate noticeTemplate = noticeTemplateService.update(id, updateRequest);
        if (noticeTemplate == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new NoticeTemplatesResponse(List.of(noticeTemplate)), null, requestId);
    }

    @DeleteMapping(API_NOTICE_TEMPLATES_ID)
    @Operation(summary = "Delete notice template by id.", description = "Delete a single notice template by its id.")
    @ApiResponse(responseCode = "204", description = "Notice template deleted.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> delete(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        noticeTemplateService.delete(id);
        return ResponseEntity.noContent().build();
    }

}

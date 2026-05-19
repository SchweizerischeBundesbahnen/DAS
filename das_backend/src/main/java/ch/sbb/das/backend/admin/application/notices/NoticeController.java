package ch.sbb.das.backend.admin.application.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeByIdsDeleteRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatch;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticeMatchesResponse;
import ch.sbb.das.backend.admin.application.notices.model.NoticeRequest;
import ch.sbb.das.backend.admin.application.notices.model.NoticeResponse;
import ch.sbb.das.backend.admin.domain.notices.NoticeMatchService;
import ch.sbb.das.backend.admin.domain.notices.NoticeService;
import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
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
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Notices", description = "API for notices.")
public class NoticeController {

    static final String PATH_SEGMENT_NOTICES = "/notices";
    public static final String API_NOTICES = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_NOTICES;
    public static final String API_NOTICES_MATCHES = API_NOTICES + "/matches";
    static final String API_NOTICES_ID = API_NOTICES + "/{id}";

    private final NoticeService noticeService;
    private final NoticeMatchService noticeMatchService;

    public NoticeController(NoticeService noticeService, NoticeMatchService noticeMatchService) {
        this.noticeService = noticeService;
        this.noticeMatchService = noticeMatchService;
    }

    @GetMapping(API_NOTICES)
    @Operation(summary = "Get all notices.", description = "Returns all notices visible for the authorized companies.")
    @ApiResponse(responseCode = "200", description = "Notices found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<Notice> notices = noticeService.getAll();
        return ResponseEntityFactory.createOkResponse(new NoticeResponse(notices), null, requestId);
    }

    @GetMapping(API_NOTICES_ID)
    @Operation(summary = "Get notice by id.", description = "Returns a single notice by its id.")
    @ApiResponse(responseCode = "200", description = "Notice found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeResponse.class)))
    @ApiResponse(responseCode = "404", description = "Notice not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Notice notice = noticeService.getById(id);
        if (notice == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new NoticeResponse(notice), null, requestId);
    }

    @PostMapping(API_NOTICES)
    @Operation(summary = "Create new notice.", description = "Creates a new notice entry.")
    @ApiResponse(responseCode = "201", description = "Notice created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeResponse.class)))
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canAccessCompanies(#createRequest.scope.companies)")
    public ResponseEntity<NoticeResponse> create(@RequestBody @Valid NoticeRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Notice createdNotice = noticeService.create(createRequest);
        HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        return new ResponseEntity<>(new NoticeResponse(createdNotice), headers, HttpStatus.CREATED);
    }

    @PostMapping(API_NOTICES_MATCHES)
    @Operation(summary = "Get notice matches.",
        description = "Filters notices for one company, train number and start date, and returns requested TAF/TAP location references with their matched notice contents in one resolved language. "
            + "If the request train number is a shadow train, train filtering also checks the corresponding original train number (-70'000). Date filtering considers special holiday schedule mapping.")
    @ApiResponse(responseCode = "200", description = "Notice matches found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeMatchesResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> findMatches(@RequestBody @Valid NoticeMatchesRequest filterRequest,
        @RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, required = false) String acceptLanguage,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<NoticeMatch> noticeMatches = noticeMatchService.findMatches(filterRequest, acceptLanguage);
        return ResponseEntityFactory.createOkResponse(new NoticeMatchesResponse(noticeMatches), null, requestId);
    }

    @PutMapping(API_NOTICES_ID)
    @Operation(summary = "Update notice by id.", description = "Updates a single notice by its id.")
    @ApiResponse(responseCode = "200", description = "Notice updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = NoticeResponse.class)))
    @ApiResponse(responseCode = "404", description = "Notice not found.")
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canAccessCompanies(#updateRequest.scope.companies)")
    public ResponseEntity<? extends Response> update(@PathVariable Integer id, @RequestBody @Valid NoticeRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Notice updatedNotice = noticeService.update(id, updateRequest);
        if (updatedNotice == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new NoticeResponse(updatedNotice), null, requestId);
    }

    @DeleteMapping(API_NOTICES_ID)
    @Operation(summary = "Delete notice by id.", description = "Deletes a single notice by its id.")
    @ApiResponse(responseCode = "204", description = "Notice deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> delete(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        noticeService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping(API_NOTICES)
    @Operation(summary = "Delete notices by ids.", description = "Deletes multiple notices in a single request.")
    @ApiResponse(responseCode = "204", description = "Notices deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteNoticeByIds(@RequestBody @Valid NoticeByIdsDeleteRequest deleteRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        noticeService.delete(deleteRequest.ids());
        return ResponseEntity.noContent().build();
    }
}

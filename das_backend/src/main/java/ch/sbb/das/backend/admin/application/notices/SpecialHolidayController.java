package ch.sbb.das.backend.admin.application.notices;

import ch.sbb.das.backend.admin.application.notices.model.SpecialHoliday;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidayByIdsDeleteRequest;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidayRequest;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidayResponse;
import ch.sbb.das.backend.admin.application.notices.model.SpecialHolidaysResponse;
import ch.sbb.das.backend.admin.domain.notices.SpecialHolidayService;
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
@Tag(name = "Special holidays", description = "API to manage special holidays.")
public class SpecialHolidayController {

    static final String PATH_SEGMENT_SPECIAL_HOLIDAYS = "/special-holidays";
    public static final String API_SPECIAL_HOLIDAYS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_SPECIAL_HOLIDAYS;
    static final String API_SPECIAL_HOLIDAYS_ID = API_SPECIAL_HOLIDAYS + "/{id}";

    private final SpecialHolidayService specialHolidayService;

    public SpecialHolidayController(SpecialHolidayService specialHolidayService) {
        this.specialHolidayService = specialHolidayService;
    }

    @GetMapping(API_SPECIAL_HOLIDAYS)
    @Operation(summary = "Get all special holidays.", description = "Returns all special holidays.")
    @ApiResponse(responseCode = "200", description = "Special holidays found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SpecialHolidaysResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllUpcomingSpecialHolidays(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<SpecialHoliday> specialHolidays = specialHolidayService.getAllUpcoming();
        return ResponseEntityFactory.createOkResponse(new SpecialHolidaysResponse(specialHolidays), null, requestId);
    }

    @GetMapping(API_SPECIAL_HOLIDAYS_ID)
    @Operation(summary = "Get special holiday by id.", description = "Returns a single special holiday by its id.")
    @ApiResponse(responseCode = "200", description = "Special holiday found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SpecialHolidayResponse.class)))
    @ApiResponse(responseCode = "404", description = "Special holiday not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getSpecialHolidayById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        SpecialHoliday specialHoliday = specialHolidayService.getById(id);
        if (specialHoliday == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new SpecialHolidayResponse(specialHoliday), null, requestId);
    }

    @PostMapping(API_SPECIAL_HOLIDAYS)
    @Operation(summary = "Create new special holiday.", description = "Creates a new special holiday entry.")
    @ApiResponse(responseCode = "201", description = "Special holiday created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SpecialHolidayResponse.class)))
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canAccessCompanies(#createRequest.companies)")
    public ResponseEntity<SpecialHolidayResponse> createSpecialHoliday(@RequestBody @Valid SpecialHolidayRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        SpecialHoliday createdSpecialHoliday = specialHolidayService.create(createRequest);
        HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        return new ResponseEntity<>(new SpecialHolidayResponse(createdSpecialHoliday), headers, HttpStatus.CREATED);
    }

    @PutMapping(API_SPECIAL_HOLIDAYS_ID)
    @Operation(summary = "Update special holiday by id.", description = "Updates a single special holiday by its id.")
    @ApiResponse(responseCode = "200", description = "Special holiday updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SpecialHolidayResponse.class)))
    @ApiResponse(responseCode = "404", description = "Special holiday not found.")
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canAccessCompanies(#updateRequest.companies)")
    public ResponseEntity<? extends Response> updateSpecialHoliday(@PathVariable Integer id, @RequestBody @Valid SpecialHolidayRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        SpecialHoliday updatedSpecialHoliday = specialHolidayService.update(id, updateRequest);
        if (updatedSpecialHoliday == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new SpecialHolidayResponse(updatedSpecialHoliday), null, requestId);
    }

    @DeleteMapping(API_SPECIAL_HOLIDAYS_ID)
    @Operation(summary = "Delete special holiday by id.", description = "Delete a single special holiday by its id.")
    @ApiResponse(responseCode = "204", description = "Special holiday deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteSpecialHoliday(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        specialHolidayService.deleteByIds(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping(API_SPECIAL_HOLIDAYS)
    @Operation(summary = "Delete special holiday by ids.", description = "Delete multiple special holiday entries in a single request.")
    @ApiResponse(responseCode = "204", description = "Special holidays deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteSpecialHolidayByIds(@RequestBody @Valid SpecialHolidayByIdsDeleteRequest deleteRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        specialHolidayService.deleteByIds(deleteRequest.ids());
        return ResponseEntity.noContent().build();
    }
}

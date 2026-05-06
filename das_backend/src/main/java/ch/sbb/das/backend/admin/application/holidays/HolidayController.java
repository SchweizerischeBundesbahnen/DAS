package ch.sbb.das.backend.admin.application.holidays;

import ch.sbb.das.backend.admin.application.holidays.model.Holiday;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayBatchDeleteRequest;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayRequest;
import ch.sbb.das.backend.admin.application.holidays.model.HolidayResponse;
import ch.sbb.das.backend.admin.application.holidays.model.HolidaysResponse;
import ch.sbb.das.backend.admin.domain.holidays.HolidayService;
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
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Holidays", description = "API for holidays.")
public class HolidayController {

    static final String PATH_SEGMENT_HOLIDAYS = "/holidays";
    public static final String API_HOLIDAYS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_HOLIDAYS;
    static final String API_HOLIDAYS_ID = API_HOLIDAYS + "/{id}";

    private final HolidayService holidayService;

    public HolidayController(HolidayService holidayService) {
        this.holidayService = holidayService;
    }

    @GetMapping(API_HOLIDAYS)
    @Operation(summary = "Get all holidays.", description = "Returns all holidays.")
    @ApiResponse(responseCode = "200", description = "Holidays found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = HolidaysResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<Holiday> holidays = holidayService.getAll();
        return ResponseEntityFactory.createOkResponse(new HolidaysResponse(holidays), null, requestId);
    }

    @GetMapping(API_HOLIDAYS_ID)
    @Operation(summary = "Get holiday by id.", description = "Returns a single holiday by its id.")
    @ApiResponse(responseCode = "200", description = "Holiday found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = HolidayResponse.class)))
    @ApiResponse(responseCode = "404", description = "Holiday not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getById(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Holiday holiday = holidayService.getById(id);
        if (holiday == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new HolidayResponse(holiday), null, requestId);
    }

    @PostMapping(API_HOLIDAYS)
    @Operation(summary = "Create new holiday.", description = "Creates a new holiday entry.")
    @ApiResponse(responseCode = "201", description = "Holiday created.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = HolidayResponse.class)))
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canEditCompany(authentication, #createRequest.companies)")
    public ResponseEntity<HolidayResponse> create(@RequestBody @Valid HolidayRequest createRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        Authentication authentication) {
        Holiday createdHoliday = holidayService.create(createRequest);
        HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        return new ResponseEntity<>(new HolidayResponse(createdHoliday), headers, HttpStatus.CREATED);
    }

    @PutMapping(API_HOLIDAYS_ID)
    @Operation(summary = "Update holiday by id.", description = "Updates a single holiday by its id.")
    @ApiResponse(responseCode = "200", description = "Holiday updated.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = HolidayResponse.class)))
    @ApiResponse(responseCode = "404", description = "Holiday not found.")
    @ApiErrorResponses
    @PreAuthorize("@companyAuthorizer.canEditCompany(authentication, #updateRequest.companies)")
    public ResponseEntity<? extends Response> update(@PathVariable Integer id, @RequestBody @Valid HolidayRequest updateRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        Authentication authentication) {
        Holiday updatedHoliday = holidayService.update(id, updateRequest);
        if (updatedHoliday == null) {
            return ResponseEntityFactory.createNotFoundResponse(requestId, null);
        }
        return ResponseEntityFactory.createOkResponse(new HolidayResponse(updatedHoliday), null, requestId);
    }

    @DeleteMapping(API_HOLIDAYS_ID)
    @Operation(summary = "Delete holiday by id.", description = "Delete a single holiday by its id.")
    @ApiResponse(responseCode = "204", description = "Holiday deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> delete(@PathVariable Integer id,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        holidayService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping(API_HOLIDAYS)
    @Operation(summary = "Delete holidays by ids.", description = "Delete multiple holidays in a single request.")
    @ApiResponse(responseCode = "204", description = "Holidays deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteBatch(@RequestBody @Valid HolidayBatchDeleteRequest deleteRequest,
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        holidayService.delete(deleteRequest.ids());
        return ResponseEntity.noContent().build();
    }
}


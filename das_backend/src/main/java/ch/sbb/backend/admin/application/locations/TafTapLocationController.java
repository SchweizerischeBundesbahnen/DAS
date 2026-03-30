package ch.sbb.backend.admin.application.locations;

import ch.sbb.backend.admin.application.settings.model.response.SettingsResponse;
import ch.sbb.backend.admin.domain.locations.TafTapLocation;
import ch.sbb.backend.admin.domain.locations.TafTapLocationRepository;
import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiErrorResponses;
import ch.sbb.backend.common.ApiParametersDefault;
import ch.sbb.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.backend.common.Response;
import ch.sbb.backend.common.ResponseEntityFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.headers.Header;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Location", description = "API for TAF/TAP locations.")
public class TafTapLocationController {

    static final String PATH_SEGMENT_LOCATIONS = "/locations";

    public static final String API_LOCATIONS = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_LOCATIONS;

    private final TafTapLocationRepository locationService;

    public TafTapLocationController(TafTapLocationRepository locationService) {
        this.locationService = locationService;
    }

    @GetMapping(API_LOCATIONS)
    @Operation(summary = "Fetch all locations.")
    @ApiResponse(responseCode = "200", description = "Locations successfully fetched.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = SettingsResponse.class)), headers = {
        @Header(name = ApiDocumentation.HEADER_CACHE_CONTROL, description = ApiDocumentation.HEADER_CACHE_CONTROL_RESPONSE_DESCRIPTION, schema = @Schema(type = "string")),
        @Header(name = ApiDocumentation.HEADER_CACHE_ETAG, description = ApiDocumentation.HEADER_CACHE_ETAG_RESPONSE_DESCRIPTION, schema = @Schema(type = "string", example = ApiDocumentation.SAMPLE_CACHE_ETAG))
    })
    @ApiErrorResponses
    @Parameter(name = HttpHeaders.IF_NONE_MATCH, schema = @Schema(type = "string", example = ApiDocumentation.SAMPLE_CACHE_ETAG), description = ApiDocumentation.HEADER_CACHE_IF_NONE_MATCH_DESCRIPTION,
        in = ParameterIn.HEADER)
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<TafTapLocation> locations = locationService.findAll();
        final HttpHeaders headers = ResponseEntityFactory.createOkHeaders(requestId);
        headers.add(HttpHeaders.CACHE_CONTROL, "public, max-age=86400");
        return ResponseEntityFactory.createOkResponse(
            headers,
            TafTapLocationsResponse.from(locations)
        );
    }
}

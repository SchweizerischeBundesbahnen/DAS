package ch.sbb.das.backend.cargo.api.v1;

import ch.sbb.das.backend.cargo.infrastructure.TransportPaperClient;
import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Problem;
import ch.sbb.das.backend.common.ProxyClientException;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.net.URI;
import java.time.LocalDate;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientResponseException;

@RestController
@RequiredArgsConstructor
@Tag(name = "Transport Paper", description = "Proxy endpoint resolving transport paper URLs for SBBCH (SBB Cargo only).")
public class TransportPaperController {

    private static final String PATH_SEGMENT_TRANSPORT_PAPERS = "/transport-papers";
    public static final String API_TRANSPORT_PAPERS = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_TRANSPORT_PAPERS;
    public static final String PARAM_COUNTRY_CODE_ISO = "countryCodeIso";
    public static final String PARAM_LOCATION_PRIMARY_CODE = "locationPrimaryCode";
    public static final String PARAM_PASS_INDEX = "passIndex";

    private static final String SBB_TENANT = "sbb";

    private final TransportPaperClient transportPaperClient;
    private final CompanyAuthorizer companyAuthorizer;

    @Operation(summary = "Resolve and redirect to a transport paper download URL.")
    @ApiResponse(responseCode = "302", description = "Redirect to downstream pre-signed transport paper URL")
    @ApiResponse(responseCode = "502", description = ApiDocumentation.STATUS_502,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = Problem.class)))
    @ApiErrorResponses
    @GetMapping(path = API_TRANSPORT_PAPERS + "/{trainPathId}/{operatingDay}")
    ResponseEntity<Void> resolveTransportPaperUrl(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, required = false) String acceptLanguage,
        @PathVariable String trainPathId,
        @PathVariable LocalDate operatingDay,
        @Parameter(description = "ISO country code", required = true)
        @RequestParam(name = PARAM_COUNTRY_CODE_ISO) String countryCodeIso,
        @Parameter(description = "Primary location code without check digit", required = true)
        @RequestParam(name = PARAM_LOCATION_PRIMARY_CODE) Integer locationPrimaryCode,
        @Parameter(description = "Running number for repeated location traversals", required = true)
        @RequestParam(name = PARAM_PASS_INDEX) Integer passIndex
    ) {
        companyAuthorizer.requireCanAccessTenant(SBB_TENANT);
        try {
            String downloadUrl = transportPaperClient.getDownloadUrl(trainPathId, operatingDay, countryCodeIso, locationPrimaryCode, passIndex, acceptLanguage);
            return ResponseEntity.status(HttpStatus.FOUND).location(URI.create(downloadUrl)).build();
        } catch (RestClientResponseException ex) {
            throw new ProxyClientException(ex.getStatusCode(), ex.getResponseBodyAsString());
        }
    }
}

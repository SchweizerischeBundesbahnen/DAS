package ch.sbb.das.backend.tenancy.application;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.common.CompanyShortName;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.tenancy.application.model.CompaniesResponse;
import ch.sbb.das.backend.tenancy.application.model.Company;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyCodeRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.List;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Companies", description = "API for companies available to the authenticated user.")
public class CompanyController {

    static final String PATH_SEGMENT_COMPANIES = "/companies";
    public static final String API_COMPANIES = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_COMPANIES;

    private final CompanyCodeRepository companyCodeRepository;
    private final CompanyAuthorizer companyAuthorizer;

    public CompanyController(CompanyCodeRepository companyCodeRepository, CompanyAuthorizer companyAuthorizer) {
        this.companyCodeRepository = companyCodeRepository;
        this.companyAuthorizer = companyAuthorizer;
    }

    @GetMapping(API_COMPANIES)
    @Operation(summary = "Get companies.", description = "Returns the companies available to the authenticated user.")
    @ApiResponse(responseCode = "200", description = "Companies found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = CompaniesResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        Authentication authentication) {
        Map<CompanyCode, CompanyShortName> uicMap = companyCodeRepository.getAll();
        List<Company> companies = companyAuthorizer.getCompanyCodes(authentication).stream()
            .filter(uicMap::containsKey)
            .map(code -> new Company(code.getValue(), uicMap.get(code).getValue()))
            .toList();
        return ResponseEntityFactory.createOkResponse(new CompaniesResponse(companies), null, requestId);
    }
}

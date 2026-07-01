package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "Companies", description = "API for companies available to the authenticated user.")
public class CompanyController {

    private static final String PATH_SEGMENT_COMPANIES = "/companies";
    public static final String API_COMPANIES = ApiDocumentation.ADMIN_URI + PATH_SEGMENT_COMPANIES;

    private final CompanyService companyService;
    private final CompanyAuthorizer companyAuthorizer;

    public CompanyController(CompanyService companyService, CompanyAuthorizer companyAuthorizer) {
        this.companyService = companyService;
        this.companyAuthorizer = companyAuthorizer;
    }

    @GetMapping(API_COMPANIES)
    @Operation(summary = "Get companies.", description = "Returns the companies available to the authenticated user.")
    @ApiResponse(responseCode = "200", description = "Companies found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = CompanyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAll(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Map<CompanyCode, CompanyShortName> uicMap = companyService.getAllCompanies();
        List<Company> companies = companyAuthorizer.authorizedCompanies().stream()
            .filter(uicMap::containsKey)
            .map(code -> new Company(code.value(), uicMap.get(code).value()))
            .sorted(Comparator.comparing(Company::shortName))
            .toList();
        return ResponseEntityFactory.createOkResponse(new CompanyResponse(companies), requestId);
    }
}

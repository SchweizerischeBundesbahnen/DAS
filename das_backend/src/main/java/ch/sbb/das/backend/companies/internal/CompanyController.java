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
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
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
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "Companies", description = "Admin API for managing companies.")
public class CompanyController {

    private static final String PATH_SEGMENT_COMPANIES = "/companies";
    public static final String API_COMPANIES = ApiDocumentation.ADMIN_URI + PATH_SEGMENT_COMPANIES;
    static final String API_COMPANIES_ID = API_COMPANIES + "/{id}";
    static final String API_COMPANIES_AUTHORIZED = API_COMPANIES + "/authorized";
    private static final String PATH_SEGMENT_TENANTS = "/tenants";
    public static final String API_TENANTS = ApiDocumentation.ADMIN_URI + PATH_SEGMENT_TENANTS;

    private final CompanyServiceImpl companyService;
    private final CompanyAuthorizer companyAuthorizer;

    @GetMapping(API_COMPANIES)
    @Operation(summary = "Get all companies.", description = "Returns all companies (admin only).")
    @ApiResponse(responseCode = "200", description = "Companies found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalCompanyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllCompanies(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        List<InternalCompany> companies = companyService.getAllAdminCompanies();
        return ResponseEntityFactory.createOkResponse(new InternalCompanyResponse(companies), requestId);
    }

    @GetMapping(API_COMPANIES_AUTHORIZED)
    @Operation(summary = "Get authorized companies.", description = "Returns the companies the authenticated tenant is authorized for.")
    @ApiResponse(responseCode = "200", description = "Companies found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = CompanyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAuthorizedCompanies(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        Set<CompanyCode> authorizedCodes = companyAuthorizer.authorizedCompanies();
        List<Company> companies = companyService.getAllCompanies().stream()
            .filter(company -> authorizedCodes.contains(company.code()))
            .sorted(Comparator.comparing(Company::shortName))
            .toList();
        return ResponseEntityFactory.createOkResponse(new CompanyResponse(companies), requestId);
    }

    @GetMapping(API_COMPANIES_ID)
    @Operation(summary = "Get company by id.", description = "Returns a single company by its id.")
    @ApiResponse(responseCode = "200", description = "Company found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalCompanyResponse.class)))
    @ApiResponse(responseCode = "404", description = "Company not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getCompanyById(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        Optional<InternalCompany> company = companyService.getById(id);
        if (company.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new InternalCompanyResponse(company.get()), requestId);
        }
        return ResponseEntityFactory.createNotFoundResponse(requestId, null);
    }

    @PostMapping(API_COMPANIES)
    @Operation(summary = "Create a new company.", description = "Creates a new company entry assigned to a tenant.")
    @ApiResponse(responseCode = "201", description = "Company created.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalCompanyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> createCompany(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody @Valid CompanyRequest createRequest) {
        InternalCompany company = companyService.create(createRequest);
        return ResponseEntityFactory.createCreatedResponse(new InternalCompanyResponse(company), requestId);
    }

    @PutMapping(API_COMPANIES_ID)
    @Operation(summary = "Update company by id.", description = "Updates a company by its id.")
    @ApiResponse(responseCode = "200", description = "Company updated.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = InternalCompanyResponse.class)))
    @ApiResponse(responseCode = "404", description = "Company not found.")
    @ApiErrorResponses
    public ResponseEntity<? extends Response> updateCompany(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id,
        @RequestBody @Valid CompanyRequest updateRequest) {
        Optional<InternalCompany> company = companyService.update(id, updateRequest);
        if (company.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new InternalCompanyResponse(company.orElse(null)), requestId);
        }
        return ResponseEntityFactory.createNotFoundResponse(requestId, null);
    }

    @DeleteMapping(API_COMPANIES_ID)
    @Operation(summary = "Delete company by id.", description = "Deletes a company by its id.")
    @ApiResponse(responseCode = "204", description = "Company deleted.")
    @ApiResponse(responseCode = "404", description = "Company not found.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteCompany(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable Integer id) {
        companyService.delete(id);
        return ResponseEntityFactory.createNoContentResponse(requestId);
    }

    @GetMapping(API_TENANTS)
    @Operation(summary = "Get tenants.", description = "Returns all available tenants for selection.")
    @ApiResponse(responseCode = "200", description = "Tenants found.", content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = TenantResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllTenants(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId) {
        return ResponseEntityFactory.createOkResponse(new TenantResponse(companyService.getAllTenants()), requestId);
    }
}

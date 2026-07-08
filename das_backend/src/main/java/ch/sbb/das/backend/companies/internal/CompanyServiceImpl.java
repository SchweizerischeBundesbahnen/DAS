package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.List;
import java.util.Optional;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

@Component
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    private final CompanyRepository companyRepository;
    private final TenantRepository tenantRepository;
    private final CompanyMapper companyMapper;

    private static String extractTenantIdFromIssuerUri(String issuerUri) {
        if (!issuerUri.startsWith(Tenant.ENTRA_BASE_URL)) {
            throw new IllegalArgumentException("unknown tenant");
        }
        String path = issuerUri.substring(Tenant.ENTRA_BASE_URL.length());
        int slashIndex = path.indexOf('/');
        return slashIndex > 0 ? path.substring(0, slashIndex) : path;
    }

    @Override
    public Optional<CompanyCode> findCompanyCodeByShortName(CompanyShortName shortName) {
        return companyRepository.findByShortName(shortName.value())
            .map(entity -> new CompanyCode(entity.getCode()));
    }

    @Override
    public List<Company> getAllCompanies() {
        return companyRepository.findAll().stream()
            .map(companyMapper::toCompany)
            .toList();
    }

    @Override
    public Tenant getTenantByIssuerUri(@NonNull String issuerUri) {
        String tenantId = extractTenantIdFromIssuerUri(issuerUri);
        return tenantRepository.findByTenantId(tenantId)
            .map(companyMapper::toTenant)
            .orElseThrow(() -> new IllegalArgumentException("unknown tenant"));
    }

    List<AdminCompany> getAllAdminCompanies() {
        return companyRepository.findAll().stream()
            .map(companyMapper::toAdminCompany)
            .toList();
    }

    Optional<AdminCompany> getById(Integer id) {
        return companyRepository.findById(id)
            .map(companyMapper::toAdminCompany);
    }

    AdminCompany create(CompanyRequest request) {
        TenantEntity tenant = findTenantOrThrow(request.tenantId());
        if (companyRepository.existsByCode(request.code().value())) {
            throw new ConflictException("Company code already exists: " + request.code().value());
        }
        if (companyRepository.existsByShortName(request.shortName().value())) {
            throw new ConflictException("Company short name already exists: " + request.shortName().value());
        }
        CompanyEntity entity = companyMapper.toEntity(request, tenant);
        return companyMapper.toAdminCompany(companyRepository.save(entity));
    }

    Optional<AdminCompany> update(Integer id, CompanyRequest request) {
        Optional<CompanyEntity> optional = companyRepository.findById(id);
        if (optional.isEmpty()) {
            return Optional.empty();
        }
        TenantEntity tenant = findTenantOrThrow(request.tenantId());
        if (companyRepository.existsByCodeAndIdNot(request.code().value(), id)) {
            throw new ConflictException("Company code already exists: " + request.code().value());
        }
        if (companyRepository.existsByShortNameAndIdNot(request.shortName().value(), id)) {
            throw new ConflictException("Company short name already exists: " + request.shortName().value());
        }
        CompanyEntity entity = optional.get();
        companyMapper.updateEntity(entity, request, tenant);
        return Optional.of(companyMapper.toAdminCompany(companyRepository.save(entity)));
    }

    void delete(Integer id) {
        companyRepository.deleteById(id);
    }

    List<TenantDto> getAllTenants() {
        return tenantRepository.findAll().stream()
            .map(companyMapper::toTenantDto)
            .toList();
    }

    private TenantEntity findTenantOrThrow(String tenantId) {
        return tenantRepository.findByTenantId(tenantId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tenant not found: " + tenantId));
    }

}

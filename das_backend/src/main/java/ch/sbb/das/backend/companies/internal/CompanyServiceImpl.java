package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.common.error.BadRequestException;
import ch.sbb.das.backend.common.error.ConflictException;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.List;
import java.util.Optional;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class CompanyServiceImpl implements CompanyService {

    private static final String RESOURCE = "Company";

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

    List<InternalCompany> getAllAdminCompanies() {
        return companyRepository.findAll().stream()
            .map(companyMapper::toAdminCompany)
            .toList();
    }

    InternalCompany getById(Integer id) {
        return companyRepository.findById(id)
            .map(companyMapper::toAdminCompany)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    InternalCompany create(CompanyRequest request) {
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

    InternalCompany update(Integer id, CompanyRequest request) {
        CompanyEntity entity = companyRepository.findById(id)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
        TenantEntity tenant = findTenantOrThrow(request.tenantId());
        if (companyRepository.existsByCodeAndIdNot(request.code().value(), id)) {
            throw new ConflictException("Company code already exists: " + request.code().value());
        }
        if (companyRepository.existsByShortNameAndIdNot(request.shortName().value(), id)) {
            throw new ConflictException("Company short name already exists: " + request.shortName().value());
        }
        companyMapper.updateEntity(entity, request, tenant);
        return companyMapper.toAdminCompany(companyRepository.save(entity));
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
            .orElseThrow(() -> new BadRequestException("Tenant not found: " + tenantId));
    }

}

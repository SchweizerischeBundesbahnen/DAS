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

    AdminCompany getById(Integer id) {
        return companyRepository.findById(id)
            .map(companyMapper::toAdminCompany)
            .orElse(null);
    }

    AdminCompany create(CompanyRequest request) {
        TenantEntity tenant = findTenantOrThrow(request.tenantId());
        checkUniqueCode(request.code().value(), null);
        checkUniqueShortName(request.shortName().value(), null);
        CompanyEntity entity = companyMapper.toEntity(request, tenant);
        return companyMapper.toAdminCompany(companyRepository.save(entity));
    }

    AdminCompany update(Integer id, CompanyRequest request) {
        Optional<CompanyEntity> optional = companyRepository.findById(id);
        if (optional.isEmpty()) {
            return null;
        }
        TenantEntity tenant = findTenantOrThrow(request.tenantId());
        checkUniqueCode(request.code().value(), id);
        checkUniqueShortName(request.shortName().value(), id);
        CompanyEntity entity = optional.get();
        companyMapper.updateEntity(entity, request, tenant);
        return companyMapper.toAdminCompany(companyRepository.save(entity));
    }

    void delete(Integer id) {
        companyRepository.deleteById(id);
    }

    List<TenantDto> getAllTenants() {
        return tenantRepository.findAll().stream()
            .map(e -> new TenantDto(e.getName(), e.getTenantId()))
            .toList();
    }

    private TenantEntity findTenantOrThrow(String tenantId) {
        return tenantRepository.findByTenantId(tenantId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Tenant not found: " + tenantId));
    }

    private void checkUniqueCode(String code, Integer selfId) {
        if (companyRepository.existsByCodeAndIdNot(code, selfId != null ? selfId : -1)) {
            throw new ConflictException("Company code already exists: " + code);
        }
    }

    private void checkUniqueShortName(String shortName, Integer selfId) {
        if (companyRepository.existsByShortNameAndIdNot(shortName, selfId != null ? selfId : -1)) {
            throw new ConflictException("Company short name already exists: " + shortName);
        }
    }
}

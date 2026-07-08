package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;

@Component
class CompanyMapper {

    Company toCompany(CompanyEntity entity) {
        return new Company(new CompanyCode(entity.getCode()), new CompanyShortName(entity.getShortName()));
    }

    AdminCompany toAdminCompany(CompanyEntity entity) {
        return new AdminCompany(entity.getId(), new CompanyCode(entity.getCode()),
            new CompanyShortName(entity.getShortName()));
    }

    CompanyEntity toEntity(CompanyRequest request, TenantEntity tenant) {
        CompanyEntity entity = new CompanyEntity();
        updateEntity(entity, request, tenant);
        return entity;
    }

    void updateEntity(CompanyEntity entity, CompanyRequest request, TenantEntity tenant) {
        entity.setCode(request.code().value());
        entity.setShortName(request.shortName().value());
        entity.setTenant(tenant);
    }

    Tenant toTenant(TenantEntity entity) {
        Set<CompanyCode> companies = entity.getCompanies().stream()
            .map(c -> new CompanyCode(c.getCode()))
            .collect(Collectors.toSet());

        return new Tenant(
            entity.getName(),
            entity.getTenantId(),
            entity.isAdminRoleAllowed(),
            companies);
    }

    TenantDto toTenantDto(TenantEntity entity) {
        return new TenantDto(entity.getName(), entity.getTenantId());
    }
}

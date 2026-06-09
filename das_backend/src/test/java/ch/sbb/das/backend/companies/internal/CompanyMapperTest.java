package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import org.junit.jupiter.api.Test;

class CompanyMapperTest {

    private final CompanyMapper mapper = new CompanyMapper();

    @Test
    void toCompany_maps_entity_to_company() {
        CompanyEntity entity = new CompanyEntity();
        entity.setCode("2185");
        entity.setShortName("SBB");

        Company result = mapper.toCompany(entity);

        assertThat(result.code()).isEqualTo(new CompanyCode("2185"));
        assertThat(result.shortName()).isEqualTo(new CompanyShortName("SBB"));
    }

    @Test
    void toDto_maps_entity_to_admin_company_with_id() {
        CompanyEntity entity = new CompanyEntity();
        entity.setId(42);
        entity.setCode("1185");
        entity.setShortName("BLS");

        AdminCompany result = mapper.toAdminCompany(entity);

        assertThat(result.id()).isEqualTo(42);
        assertThat(result.code()).isEqualTo(new CompanyCode("1185"));
        assertThat(result.shortName()).isEqualTo(new CompanyShortName("BLS"));
    }

    @Test
    void toEntity_creates_entity_from_request_and_tenant() {
        CompanyRequest request = new CompanyRequest(
            new CompanyCode("2185"),
            new CompanyShortName("SBB"),
            "tenant-guid"
        );
        TenantEntity tenant = new TenantEntity();
        tenant.setId(1);
        tenant.setName("Test Tenant");

        CompanyEntity result = mapper.toEntity(request, tenant);

        assertThat(result.getCode()).isEqualTo("2185");
        assertThat(result.getShortName()).isEqualTo("SBB");
        assertThat(result.getTenant()).isSameAs(tenant);
        assertThat(result.getId()).isNull();
    }

    @Test
    void updateEntity_updates_existing_entity_fields() {
        TenantEntity oldTenant = new TenantEntity();
        oldTenant.setId(1);
        TenantEntity newTenant = new TenantEntity();
        newTenant.setId(2);

        CompanyEntity entity = new CompanyEntity();
        entity.setId(10);
        entity.setCode("2185");
        entity.setShortName("SBB");
        entity.setTenant(oldTenant);

        CompanyRequest request = new CompanyRequest(
            new CompanyCode("1185"),
            new CompanyShortName("BLS"),
            "new-tenant-guid"
        );

        mapper.updateEntity(entity, request, newTenant);

        assertThat(entity.getId()).isEqualTo(10);
        assertThat(entity.getCode()).isEqualTo("1185");
        assertThat(entity.getShortName()).isEqualTo("BLS");
        assertThat(entity.getTenant()).isSameAs(newTenant);
    }
}

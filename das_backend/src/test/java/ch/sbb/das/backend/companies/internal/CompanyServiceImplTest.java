package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.PostgresTestContainerConfiguration;
import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.List;
import java.util.Optional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;

@DataJpaTest
@Import({CompanyServiceImpl.class, CompanyMapper.class, PostgresTestContainerConfiguration.class})
@ActiveProfiles("test")
@Sql("classpath:createCompaniesAndTenants.sql")
class CompanyServiceImplTest {

    private static final String VALID_TENANT_ID = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";

    @Autowired
    private CompanyServiceImpl underTest;

    @Test
    void getTenantByIssuerUri() {
        Tenant tenant = underTest
            .getTenantByIssuerUri("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0");
        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("sbb");
        assertThat(tenant.isAdminRoleAllowed()).isTrue();
        assertThat(tenant.companies()).contains(
            new CompanyCode("1111"), new CompanyCode("2222"), new CompanyCode("3333"));
    }

    @Test
    void getTenantByIssuerUri_badUri() {
        assertThatThrownBy(() -> underTest.getTenantByIssuerUri("https://bad.issuer"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");
    }

    @Test
    void findCompanyCodeByShortName() {
        Optional<CompanyCode> result = underTest.findCompanyCodeByShortName(new CompanyShortName("MOCK_A"));
        assertThat(result).isPresent().contains(new CompanyCode("1111"));
    }

    @Test
    void findCompanyCodeByShortName_notFound() {
        Optional<CompanyCode> result = underTest.findCompanyCodeByShortName(new CompanyShortName("NONEXISTENT"));
        assertThat(result).isEmpty();
    }

    @Test
    void getAllCompanies() {
        List<Company> companies = underTest.getAllCompanies();
        assertThat(companies).hasSize(8);
    }

    @Test
    void getAllTenants() {
        List<TenantDto> tenants = underTest.getAllTenants();
        assertThat(tenants).hasSize(2);
        assertThat(tenants).anyMatch(t -> t.name().equals("sbb") && t.tenantId().equals("2cda5d11-f0ac-46b3-967d-af1b2e1bd01a"));
        assertThat(tenants).anyMatch(t -> t.name().equals("unknown-tenant") && t.tenantId().equals("3409e798-d567-49b1-9bae-f0be66427c54"));
    }

    @Test
    void create_conflict_duplicateCode() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("1111"), new CompanyShortName("UNIQUE"), VALID_TENANT_ID);
        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company code already exists");
    }

    @Test
    void create_conflict_duplicateShortName() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("NEW1"), new CompanyShortName("MOCK_A"), VALID_TENANT_ID);
        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company short name already exists");
    }

    @Test
    void update_conflict_duplicateCode() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("1111"), new CompanyShortName("UPD1"), VALID_TENANT_ID);
        assertThatThrownBy(() -> underTest.update(900, request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company code already exists");
    }

    @Test
    void update_conflict_duplicateShortName() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("8881"), new CompanyShortName("MOCK_A"), VALID_TENANT_ID);
        assertThatThrownBy(() -> underTest.update(900, request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company short name already exists");
    }

    @Test
    void update_allowsSameCodeForSameEntity() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("8881"), new CompanyShortName("RENAMED"), VALID_TENANT_ID);
        Optional<AdminCompany> result = underTest.update(900, request);
        assertThat(result).isPresent();
        assertThat(result.get().shortName()).isEqualTo(new CompanyShortName("RENAMED"));
    }

    @Test
    void update_notFound() {
        CompanyRequest request = new CompanyRequest(new CompanyCode("XXXX"), new CompanyShortName("XXXX"), VALID_TENANT_ID);
        Optional<AdminCompany> result = underTest.update(Integer.MAX_VALUE, request);
        assertThat(result).isEmpty();
    }
}

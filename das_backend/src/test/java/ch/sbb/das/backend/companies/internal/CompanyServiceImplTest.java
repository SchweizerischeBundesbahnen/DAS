package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.PostgresTestContainerConfiguration;
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

    @Autowired
    private CompanyServiceImpl underTest;

    @Test
    void getTenantByIssuerUri() {
        Tenant tenant = underTest
            .getTenantByIssuerUri("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0");
        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("sbb");
        assertThat(tenant.isAdmin()).isTrue();
        assertThat(tenant.companies()).containsExactlyInAnyOrder(
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
        assertThat(companies).hasSize(4);
        assertThat(companies).anyMatch(
            c -> c.code().equals(new CompanyCode("1111")) && c.shortName().equals(new CompanyShortName("MOCK_A")));
    }
}

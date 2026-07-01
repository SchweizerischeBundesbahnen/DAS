package ch.sbb.das.backend.companies;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.util.Set;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;

class CompanyAuthorizerTest {

    private static final CompanyCode COMPANY_A = new CompanyCode("2185");
    private CompanyAuthorizer underTest;
    private static final CompanyCode COMPANY_B = new CompanyCode("2585");
    private CompanyService companyService;
    private static final String EXAMPLE_ISSUER_URL = "https://issuer.example/v2.0";

    @BeforeEach
    void setUp() {
        companyService = Mockito.mock(CompanyService.class);
        underTest = new CompanyAuthorizer(companyService);
    }

    private static void mockSecurityContxt(Authentication auth) {
        SecurityContext securityContext = Mockito.mock(SecurityContext.class);
        Mockito.when(securityContext.getAuthentication()).thenReturn(auth);
        SecurityContextHolder.setContext(securityContext);
    }

    @AfterEach
    void tearDown() {
        SecurityContextHolder.clearContext();
    }

    private static JwtAuthenticationToken mockJwt() {
        Jwt jwt = Jwt.withTokenValue("token")
            .header("alg", "none")
            .issuer(EXAMPLE_ISSUER_URL)
            .subject("sub")
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(3600))
            .claim("preferred_username", "user")
            .build();

        return new JwtAuthenticationToken(jwt);
    }

    private static Tenant tenantWithCompanies(String name, Set<CompanyCode> companies) {
        return new Tenant(name, EXAMPLE_ISSUER_URL, "", companies);
    }

    @Test
    void requireCanAccessCompanies_ok() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of(COMPANY_A, COMPANY_B));

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        assertThatCode(() -> underTest.requireCanAccessCompanies(Set.of(COMPANY_A))).doesNotThrowAnyException();
    }

    @Test
    void requireCanAccessCompanies_throws() {
        Set<CompanyCode> companies = Set.of(COMPANY_A);

        assertThatThrownBy(() -> underTest.requireCanAccessCompanies(companies))
            .isInstanceOf(AccessDeniedException.class)
            .hasMessageContaining("Not allowed");
    }

    @Test
    void canAccessCompanies_returnsFalse_whenCompaniesIsEmpty() {
        boolean result = underTest.canAccessCompanies(Set.of());

        assertThat(result).isFalse();
        verifyNoInteractions(companyService);
    }

    @Test
    void canAccessCompanies_returnsFalse_whenCompaniesIsNull() {
        boolean result = underTest.canAccessCompanies(null);

        assertThat(result).isFalse();
        verifyNoInteractions(companyService);
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantCompaniesNull() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", null);

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isFalse();
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantCompaniesEmpty() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of());

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isFalse();
    }

    @Test
    void canAccessCompanies_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(mockJwt());
        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        Set<CompanyCode> companies = Set.of(COMPANY_A);
        assertThatThrownBy(() -> underTest.canAccessCompanies(companies))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(companyService).getTenantByIssuerUri(EXAMPLE_ISSUER_URL);
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNull() {
        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verifyNoInteractions(companyService);
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNotJwt() {
        mockSecurityContxt(UsernamePasswordAuthenticationToken.authenticated("test", "credentials", Set.of()));
        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verifyNoInteractions(companyService);
    }

    @Test
    void canAccessCompanies_returnsTrue_whenTenantContainsAllRequestedCompanies() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of(COMPANY_A, COMPANY_B));

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isTrue();
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantDoesNotContainAllRequestedCompanies() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of(COMPANY_A));

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A, COMPANY_B));

        assertThat(result).isFalse();
    }

    @Test
    void isAdmin_returnsFalse_whenTenantIsNotAdminTenant() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("sob", Set.of(new CompanyCode("9058")));

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);
        when(companyService.isAdminTenant(tenant)).thenReturn(false);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verify(companyService).getTenantByIssuerUri(EXAMPLE_ISSUER_URL);
        verify(companyService).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_returnsTrue_whenTenantIsAdminTenant() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("sbb", Set.of(COMPANY_A));

        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);
        when(companyService.isAdminTenant(tenant)).thenReturn(true);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isTrue();
        verify(companyService).getTenantByIssuerUri(EXAMPLE_ISSUER_URL);
        verify(companyService).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(mockJwt());
        when(companyService.getTenantByIssuerUri(EXAMPLE_ISSUER_URL))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.isAdminTenant())
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(companyService).getTenantByIssuerUri(EXAMPLE_ISSUER_URL);
    }
}

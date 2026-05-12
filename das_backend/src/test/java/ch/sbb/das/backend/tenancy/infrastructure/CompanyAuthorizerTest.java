package ch.sbb.das.backend.tenancy.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.domain.model.Tenant;
import ch.sbb.das.backend.tenancy.domain.repository.TenantRepository;
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

    private TenantRepository tenantRepository;
    private CompanyAuthorizer underTest;

    private static final CompanyCode COMPANY_A = CompanyCode.of("2185");
    private static final CompanyCode COMPANY_B = CompanyCode.of("2585");
    private static final String EXAMPLE_ISSUER_URL = "https://issuer.example/v2.0";

    @BeforeEach
    void setUp() {
        tenantRepository = Mockito.mock(TenantRepository.class);
        underTest = new CompanyAuthorizer(tenantRepository);
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

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        assertThatCode(() -> underTest.requireCanAccessCompanies(Set.of(COMPANY_A))).doesNotThrowAnyException();
    }

    @Test
    void requireCanAccessCompanies_throws() {
        assertThatThrownBy(() -> underTest.requireCanAccessCompanies(Set.of(COMPANY_A)))
            .isInstanceOf(AccessDeniedException.class)
            .hasMessageContaining("Not allowed");
    }

    @Test
    void canAccessCompanies_returnsFalse_whenCompaniesIsEmpty() {
        boolean result = underTest.canAccessCompanies(Set.of());

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canAccessCompanies_returnsFalse_whenCompaniesIsNull() {
        boolean result = underTest.canAccessCompanies(null);

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantCompaniesNull() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", null);

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isFalse();
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantCompaniesEmpty() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of());

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isFalse();
    }

    @Test
    void canAccessCompanies_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(mockJwt());
        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.canAccessCompanies(Set.of(COMPANY_A)))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(tenantRepository).getByIssuerUri(EXAMPLE_ISSUER_URL);
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNull() {
        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNotJwt() {
        mockSecurityContxt(UsernamePasswordAuthenticationToken.authenticated("test", "credentials", Set.of()));
        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canAccessCompanies_returnsTrue_whenTenantContainsAllRequestedCompanies() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of(COMPANY_A, COMPANY_B));

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A));

        assertThat(result).isTrue();
    }

    @Test
    void canAccessCompanies_returnsFalse_whenTenantDoesNotContainAllRequestedCompanies() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("t1", Set.of(COMPANY_A));

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);

        boolean result = underTest.canAccessCompanies(Set.of(COMPANY_A, COMPANY_B));

        assertThat(result).isFalse();
    }

    @Test
    void isAdmin_returnsFalse_whenTenantIsNotAdminTenant() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("sob", Set.of(CompanyCode.of("9058")));

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(false);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verify(tenantRepository).getByIssuerUri(EXAMPLE_ISSUER_URL);
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_returnsTrue_whenTenantIsAdminTenant() {
        mockSecurityContxt(mockJwt());
        Tenant tenant = tenantWithCompanies("sbb", Set.of(COMPANY_A));

        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL)).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(true);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isTrue();
        verify(tenantRepository).getByIssuerUri(EXAMPLE_ISSUER_URL);
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(mockJwt());
        when(tenantRepository.getByIssuerUri(EXAMPLE_ISSUER_URL))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.isAdminTenant())
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(tenantRepository).getByIssuerUri(EXAMPLE_ISSUER_URL);
    }
}

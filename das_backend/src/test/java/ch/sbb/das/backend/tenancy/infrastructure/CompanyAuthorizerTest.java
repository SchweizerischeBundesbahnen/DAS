package ch.sbb.das.backend.tenancy.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

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

    @Test
    void requireCanAccessCompanies_ok() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185", "2585"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        assertThatCode(() -> underTest.requireCanAccessCompanies(Set.of("2185"))).doesNotThrowAnyException();
    }

    @Test
    void requireCanAccessCompanies_throws() {
        assertThatThrownBy(() -> underTest.requireCanAccessCompanies(Set.of("2185")))
            .isInstanceOf(AccessDeniedException.class)
            .hasMessageContaining("Not allowed");
    }

    @Test
    void canEditCompanies_returnsFalse_whenCompaniesIsEmpty() {
        boolean result = underTest.canAccessCompany(Set.of());

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canEditCompanies_returnsFalse_whenCompaniesIsNull() {
        boolean result = underTest.canAccessCompany(null);

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canEditCompanies_returnsFalse_whenTenantCompaniesNull() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", null);

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canAccessCompany(Set.of("2185"));

        assertThat(result).isFalse();
    }

    @Test
    void canEditCompanies_returnsFalse_whenTenantCompaniesEmpty() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of());

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canAccessCompany(Set.of("2185"));

        assertThat(result).isFalse();
    }

    @Test
    void canEditCompanies_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0"))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.canAccessCompany(Set.of("2185")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
    }

    @Test
    void canEditCompanies_returnsTrue_whenTenantContainsAllRequestedCompanies() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185", "2585"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canAccessCompany(Set.of("2185"));

        assertThat(result).isTrue();
    }

    @Test
    void canEditCompanies_returnsFalse_whenTenantDoesNotContainAllRequestedCompanies() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canAccessCompany(Set.of("2185", "2585"));

        assertThat(result).isFalse();
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
    void isAdmin_returnsTrue_whenTenantIsAdminTenant() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("sbb", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(true);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isTrue();
        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_returnsFalse_whenTenantIsNotAdminTenant() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        Tenant tenant = tenantWithCompanies("sob", "https://issuer.example/v2.0", "https://jwks.example", Set.of("9058"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(false);

        boolean result = underTest.isAdminTenant();

        assertThat(result).isFalse();
        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        mockSecurityContxt(jwtAuthWithIssuer("https://issuer.example/v2.0"));
        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0"))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.isAdminTenant())
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
    }

    private static JwtAuthenticationToken jwtAuthWithIssuer(String issuer) {
        Jwt jwt = Jwt.withTokenValue("token")
            .header("alg", "none")
            .issuer(issuer)
            .subject("sub")
            .issuedAt(Instant.now())
            .expiresAt(Instant.now().plusSeconds(3600))
            .claim("preferred_username", "user")
            .build();

        return new JwtAuthenticationToken(jwt);
    }

    private static Tenant tenantWithCompanies(String name, String issuerUri, String jwkSetUri, Set<String> companies) {
        return new Tenant(name, issuerUri, jwkSetUri, companies);
    }
}

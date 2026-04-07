package ch.sbb.backend.tenancy.infrastructure;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.domain.repository.TenantRepository;
import java.time.Instant;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.security.core.Authentication;
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

    @Test
    void canEditCompany_returnsFalse_whenCompaniesIsEmpty() {
        Authentication auth = mock(Authentication.class);

        boolean result = underTest.canEditCompany(auth, Set.of());

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canEditCompany_returnsFalse_whenCompaniesIsNull() {
        Authentication auth = mock(Authentication.class);

        boolean result = underTest.canEditCompany(auth, null);

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void canEditCompany_returnsFalse_whenTenantCompaniesNull() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", null);

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canEditCompany(auth, Set.of("2185"));

        assertThat(result).isFalse();
    }

    @Test
    void canEditCompany_returnsFalse_whenTenantCompaniesEmpty() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of());

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canEditCompany(auth, Set.of("2185"));

        assertThat(result).isFalse();
    }

    @Test
    void canEditCompany_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0"))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.canEditCompany(auth, Set.of("2185")))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");

        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
    }

    @Test
    void canEditCompany_returnsTrue_whenTenantContainsAllRequestedCompanies() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185", "2585"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canEditCompany(auth, Set.of("2185"));

        assertThat(result).isTrue();
    }

    @Test
    void canEditCompany_returnsFalse_whenTenantDoesNotContainAllRequestedCompanies() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("t1", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);

        boolean result = underTest.canEditCompany(auth, Set.of("2185", "2585"));

        assertThat(result).isFalse();
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNull() {
        boolean result = underTest.isAdminTenant(null);

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void isAdmin_returnsFalse_whenAuthenticationIsNotJwt() {
        Authentication auth = mock(Authentication.class);

        boolean result = underTest.isAdminTenant(auth);

        assertThat(result).isFalse();
        verifyNoInteractions(tenantRepository);
    }

    @Test
    void isAdmin_returnsTrue_whenTenantIsAdminTenant() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("sbb", "https://issuer.example/v2.0", "https://jwks.example", Set.of("2185"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(true);

        boolean result = underTest.isAdminTenant(auth);

        assertThat(result).isTrue();
        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_returnsFalse_whenTenantIsNotAdminTenant() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        Tenant tenant = tenantWithCompanies("sob", "https://issuer.example/v2.0", "https://jwks.example", Set.of("9058"));

        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0")).thenReturn(tenant);
        when(tenantRepository.isAdminTenant(tenant)).thenReturn(false);

        boolean result = underTest.isAdminTenant(auth);

        assertThat(result).isFalse();
        verify(tenantRepository).getByIssuerUri("https://issuer.example/v2.0");
        verify(tenantRepository).isAdminTenant(tenant);
    }

    @Test
    void isAdmin_throws_whenTenantRepositoryDoesNotKnowIssuer() {
        JwtAuthenticationToken auth = jwtAuthWithIssuer("https://issuer.example/v2.0");
        when(tenantRepository.getByIssuerUri("https://issuer.example/v2.0"))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        assertThatThrownBy(() -> underTest.isAdminTenant(auth))
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

package ch.sbb.backend.tenancy.inftrastructure.config;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.backend.tenancy.domain.model.Tenant;
import ch.sbb.backend.tenancy.infrastructure.ConfigTenantRepository;
import ch.sbb.backend.tenancy.infrastructure.config.TenantConfig;
import ch.sbb.backend.tenancy.infrastructure.config.TenantJWSKeySelector;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.KeySourceException;
import com.nimbusds.jwt.JWTClaimsSet;
import java.security.Key;
import java.util.List;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

@SpringBootTest(classes = TenantConfig.class)
@ActiveProfiles("test")
class TenantJWSKeySelectorTest {

    private final static JWSHeader JWS_HEADER = new JWSHeader(JWSAlgorithm.RS256);

    @Autowired
    private TenantConfig tenantConfig;

    private TenantJWSKeySelector tenantJWSKeySelector;

    @BeforeEach
    void setUp() {
        final ConfigTenantRepository tenantRepository = new ConfigTenantRepository(tenantConfig);
        tenantJWSKeySelector = new TenantJWSKeySelector(tenantRepository);
    }

    @Test
    void selectKeys_tenantSBB() throws KeySourceException {
        final List<? extends Key> keys = tenantJWSKeySelector.selectKeys(JWS_HEADER, createDummyClaimsSet(tenantConfig.getTenants().getFirst()), null);
        assertThat(keys).as("Issuer-Uri and JWT-set checked for found Tenant").hasSizeGreaterThan(0);
    }

    @Test
    void selectKeys_badTenantId() {
        assertThatThrownBy(() -> tenantJWSKeySelector.selectKeys(JWS_HEADER, createDummyClaimsSet(tenantConfig.getTenants().get(1)), null))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Couldn't retrieve remote JWK set");
    }

    private static JWTClaimsSet createDummyClaimsSet(Tenant tenant) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("nonce", "13234-3234345-34454");

        return new JWTClaimsSet.Builder()
            .issuer(tenant.issuerUri())
            .subject("did:example:user123")
            .claim("verifiablePresentationJson", jsonObject)
            .build();
    }
}

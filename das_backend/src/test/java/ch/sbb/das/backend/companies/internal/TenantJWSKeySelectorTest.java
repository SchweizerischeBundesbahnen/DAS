package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ch.sbb.das.backend.companies.Tenant;
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

@SpringBootTest(classes = ApplicationConfiguration.class)
@ActiveProfiles("test")
class TenantJWSKeySelectorTest {

    private static final JWSHeader JWS_HEADER = new JWSHeader(JWSAlgorithm.RS256);

    @Autowired
    private ApplicationConfiguration applicationConfiguration;

    private TenantJWSKeySelector underTest;

    @BeforeEach
    void setUp() {
        final CompanyServiceImpl companyService = new CompanyServiceImpl(applicationConfiguration);
        underTest = new TenantJWSKeySelector(companyService);
    }

    @Test
    void selectKeys_tenantSBB() throws KeySourceException {
        final List<? extends Key> keys = underTest.selectKeys(JWS_HEADER, createDummyClaimsSet(applicationConfiguration.getTenants().getFirst()), null);
        assertThat(keys).as("Issuer-Uri and JWT-set checked for found Tenant").hasSizeGreaterThan(0);
    }

    @Test
    void selectKeys_badTenantId() {
        JWTClaimsSet claims = createDummyClaimsSet(applicationConfiguration.getTenants().get(1));
        assertThatThrownBy(() -> underTest.selectKeys(JWS_HEADER, claims, null))
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

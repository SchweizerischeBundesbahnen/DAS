package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.Tenant;
import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.KeySourceException;
import com.nimbusds.jwt.JWTClaimsSet;
import java.security.Key;
import java.util.List;
import java.util.Set;
import org.json.JSONObject;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class TenantJWSKeySelectorTest {

    private static final JWSHeader JWS_HEADER = new JWSHeader(JWSAlgorithm.RS256);
    private static final String SBB_TENANT_ID = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";
    private static final String SBB_ISSUER = "https://login.microsoftonline.com/" + SBB_TENANT_ID + "/v2.0";
    private static final String UNKNOWN_TENANT_ID = "00000000-0000-0000-0000-000000000000";
    private static final String UNKNOWN_ISSUER = "https://login.microsoftonline.com/" + UNKNOWN_TENANT_ID + "/v2.0";

    @Mock
    private CompanyService companyService;

    private TenantJWSKeySelector underTest;

    private static JWTClaimsSet createDummyClaimsSet(String issuer) {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("nonce", "13234-3234345-34454");

        return new JWTClaimsSet.Builder()
            .issuer(issuer)
            .subject("did:example:user123")
            .claim("verifiablePresentationJson", jsonObject)
            .build();
    }

    @BeforeEach
    void setUp() {
        underTest = new TenantJWSKeySelector(companyService);
    }

    @Test
    void selectKeys_tenantSBB() throws KeySourceException {
        Tenant sbbTenant = new Tenant("sbb", SBB_TENANT_ID, true, Set.of(new CompanyCode("2185")));
        when(companyService.getTenantByIssuerUri(SBB_ISSUER)).thenReturn(sbbTenant);

        final List<? extends Key> keys = underTest.selectKeys(JWS_HEADER, createDummyClaimsSet(SBB_ISSUER), null);
        assertThat(keys).as("Issuer-Uri and JWT-set checked for found Tenant").hasSizeGreaterThan(0);
    }

    @Test
    void selectKeys_unknownTenant() {
        when(companyService.getTenantByIssuerUri(UNKNOWN_ISSUER))
            .thenThrow(new IllegalArgumentException("unknown tenant"));

        JWTClaimsSet claims = createDummyClaimsSet(UNKNOWN_ISSUER);
        assertThatThrownBy(() -> underTest.selectKeys(JWS_HEADER, claims, null))
            .isInstanceOf(IllegalArgumentException.class);
    }
}

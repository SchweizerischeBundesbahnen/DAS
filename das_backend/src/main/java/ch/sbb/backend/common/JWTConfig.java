package ch.sbb.backend.common;

import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;
import com.nimbusds.jwt.proc.JWTClaimsSetAwareJWSKeySelector;
import com.nimbusds.jwt.proc.JWTProcessor;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimNames;
import org.springframework.security.oauth2.jwt.JwtClaimValidator;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

/**
 * @see WebSecurityConfig
 */
@Configuration
public class JWTConfig {

    @Value("${auth.audience.service-name}")
    private String serviceName;

    @Bean
    public JWTProcessor<SecurityContext> jwtProcessor(JWTClaimsSetAwareJWSKeySelector<SecurityContext> keySelector) {
        DefaultJWTProcessor<SecurityContext> jwtProcessor = new DefaultJWTProcessor<>();
        jwtProcessor.setJWTClaimsSetAwareJWSKeySelector(keySelector);
        return jwtProcessor;
    }

    @Bean
    public JwtDecoder jwtDecoder(JWTProcessor<SecurityContext> jwtProcessor) {
        NimbusJwtDecoder decoder = new NimbusJwtDecoder(jwtProcessor);
        OAuth2TokenValidator<Jwt> audienceValidator = new JwtClaimValidator<List<String>>(JwtClaimNames.AUD, aud -> aud.contains(serviceName));
        OAuth2TokenValidator<Jwt> validator = new DelegatingOAuth2TokenValidator<>(JwtValidators.createDefault(), audienceValidator);
        decoder.setJwtValidator(validator);
        return decoder;
    }
}


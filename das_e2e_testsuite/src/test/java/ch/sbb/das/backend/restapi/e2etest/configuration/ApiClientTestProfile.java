package ch.sbb.das.backend.restapi.e2etest.configuration;

import ch.sbb.das.backend.restapi.configuration.ApiClientConfiguration;
import ch.sbb.das.backend.restapi.configuration.DasBackendApi;
import ch.sbb.das.backend.restapi.configuration.DasBackendEndpointConfiguration;
import ch.sbb.das.backend.restapi.configuration.OAuth2Configuration;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

/**
 * Test annotation for using the generated OpenApi 3 ApiClient respectively its endpoints.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@ActiveProfiles(/*"test"*/)
@ExtendWith(SpringExtension.class)
@ContextConfiguration(classes = {DasBackendEndpointConfiguration.class, DasBackendApi.class, OAuth2Configuration.class, ApiClientConfiguration.class})
public @interface ApiClientTestProfile {

}

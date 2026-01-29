package ch.sbb.backend.common;

import static java.lang.annotation.ElementType.PARAMETER;

import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Schema;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

public final class ApiParametersDefault {

    /**
     * devOps relevant header:
     * <ul>
     *     <li>Instana-Tracing among a chane of Instana based Applications is maintained by introspection intrinsically.</li>
     *     <li>Splunk logging</li>
     * </ul>
     * <p>
     *
     * @see <a href="https://www.instana.com/docs/ecosystem/opentelemetry/">OpenTelemtry</a>
     * @see <a href="https://confluence.sbb.ch/display/MON/Instana+-+HTTP+Header+Whitelist">Request-ID</a>
     */
    public static final String HEADER_REQUEST_ID = "Request-ID";

    private ApiParametersDefault() {
    }

    @Parameter(
        in = ParameterIn.HEADER,
        name = HEADER_REQUEST_ID,
        description = ApiDocumentation.HEADER_REQUEST_ID_DESCRIPTION,
        schema = @Schema(type = "string")
    )
    // @RequestHeader as meta-annotation perhaps in future Spring version --> https://github.com/spring-projects/spring-framework/issues/21829
    @Target({PARAMETER})
    @Retention(RetentionPolicy.RUNTIME)
    public @interface ParamRequestId {

    }
}

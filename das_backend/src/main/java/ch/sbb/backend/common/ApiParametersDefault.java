package ch.sbb.backend.common;

import static java.lang.annotation.ElementType.PARAMETER;

import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Schema;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

public final class ApiParametersDefault {

    private ApiParametersDefault() {
    }

    @Parameter(
        in = ParameterIn.HEADER,
        name = MonitoringConstants.HEADER_REQUEST_ID,
        description = ApiDocumentation.HEADER_REQUEST_ID_DESCRIPTION,
        schema = @Schema(type = "string")
    )
    // @RequestHeader as meta-annotation perhaps in future Spring version --> https://github.com/spring-projects/spring-framework/issues/21829
    @Target({PARAMETER})
    @Retention(RetentionPolicy.RUNTIME)
    public @interface ParamRequestId {

    }

    //    @Parameter(
    //            in = ParameterIn.HEADER,
    //            name = HttpHeaders.ACCEPT_LANGUAGE,
    //            description = ServiceDoc.HEADER_LANGUAGE_DESCRIPTION,
    //            example = ApiDocumentation.HEADER_ACCEPT_LANGUAGE_DEFAULT,
    //        required = false,
    //        schema = @Schema(
    //            type = "string",
    //            allowableValues = {"de", "fr", "it", "en"},
    //            defaultValue = ApiDocumentation.HEADER_ACCEPT_LANGUAGE_DEFAULT)
    //    )
    //    //@RequestHeader(value = HttpHeaders.ACCEPT_LANGUAGE, defaultValue = ApiDocumentation.HEADER_ACCEPT_LANGUAGE_DEFAULT, required = false)
    //    // @RequestHeader as meta-annotation perhaps in future Spring version --> https://github.com/spring-projects/spring-framework/issues/21829
    //    @Target({PARAMETER})
    //    @Retention(RetentionPolicy.RUNTIME)
    //    public @interface ParamAcceptLanguage {
    //
    //    }
}

package ch.sbb.backend.common;

import static java.lang.annotation.ElementType.ANNOTATION_TYPE;
import static java.lang.annotation.ElementType.METHOD;
import static java.lang.annotation.ElementType.TYPE;

import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import java.lang.annotation.Inherited;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@ApiResponse(responseCode = "400", description = ApiDocumentation.STATUS_400,
    content = @Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse")))
@ApiResponse(responseCode = "401", description = ApiDocumentation.STATUS_401, content = @Content)
@ApiResponse(responseCode = "500", description = ApiDocumentation.STATUS_500,
    content = @Content(mediaType = "application/json", schema = @Schema(ref = "#/components/schemas/ErrorResponse")))
@Target({METHOD, TYPE, ANNOTATION_TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Inherited
public @interface ApiErrorResponses {

}

package ch.sbb.das.backend.userproperties.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.JsonNode;

@RestController
@RequiredArgsConstructor
@Tag(name = "User Properties", description = "API for user-specific key/value properties.")
public class UserPropertyController {

    static final String PATH_SEGMENT_USER_PROPERTIES = "/user-properties";

    public static final String API_USER_PROPERTIES = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_USER_PROPERTIES;
    static final String API_USER_PROPERTIES_KEY = API_USER_PROPERTIES + "/{key}";

    private static final String OID_CLAIM = "oid";
    private static final String KEY_PATTERN = "[a-zA-Z][a-zA-Z0-9_-]*";

    private final UserPropertyServiceImpl userPropertyService;

    @GetMapping(API_USER_PROPERTIES)
    @Operation(summary = "Get all user properties.", description = "Returns all key/value properties for the authenticated user.")
    @ApiResponse(responseCode = "200", description = "User properties found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = UserPropertyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllUserProperties(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        List<UserProperty> properties = userPropertyService.getAllByOid(oid);
        return ResponseEntityFactory.createOkResponse(new UserPropertyResponse(properties), requestId);
    }

    @GetMapping(API_USER_PROPERTIES_KEY)
    @Operation(summary = "Get a user property by key.", description = "Returns a single property value for the authenticated user by key.")
    @ApiResponse(responseCode = "200", description = "User property found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = UserPropertyResponse.class)))
    @ApiResponse(responseCode = "404", description = ApiDocumentation.STATUS_404,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = ch.sbb.das.backend.common.Problem.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getUserProperty(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable @Size(max = 64) @Pattern(regexp = KEY_PATTERN) String key,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        Optional<UserProperty> property = userPropertyService.getByOidAndKey(oid, key);
        if (property.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new UserPropertyResponse(List.of(property.get())), requestId);
        } else {
            return ResponseEntityFactory.createNotFoundResponse(requestId, API_USER_PROPERTIES + "/" + key);
        }
    }

    @PutMapping(API_USER_PROPERTIES_KEY)
    @Operation(summary = "Save a user property.", description = "Creates or updates a property value for the authenticated user. The request body can be any valid JSON.")
    @ApiResponse(responseCode = "200", description = "User property saved.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = UserPropertyResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> saveUserProperty(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable @Size(max = 64) @Pattern(regexp = KEY_PATTERN) String key,
        @RequestBody JsonNode value,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        UserProperty saved = userPropertyService.save(oid, key, value);
        return ResponseEntityFactory.createOkResponse(new UserPropertyResponse(List.of(saved)), requestId);
    }

    @DeleteMapping(API_USER_PROPERTIES_KEY)
    @Operation(summary = "Delete a user property.", description = "Deletes a single property for the authenticated user by key. Idempotent: succeeds whether or not the key exists.")
    @ApiResponse(responseCode = "204", description = "User property deleted.")
    @ApiErrorResponses
    public ResponseEntity<Void> deleteUserProperty(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable @Size(max = 64) @Pattern(regexp = KEY_PATTERN) String key,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        userPropertyService.delete(oid, key);
        return ResponseEntityFactory.createNoContentResponse(requestId);
    }
}

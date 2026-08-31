package ch.sbb.das.backend.personalnotes.internal;

import ch.sbb.das.backend.common.ApiDocumentation;
import ch.sbb.das.backend.common.ApiErrorResponses;
import ch.sbb.das.backend.common.ApiParametersDefault;
import ch.sbb.das.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.das.backend.common.Response;
import ch.sbb.das.backend.common.ResponseEntityFactory;
import ch.sbb.das.backend.personalnotes.PersonalNote;
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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import tools.jackson.databind.JsonNode;

@RestController
@RequiredArgsConstructor
@Tag(name = "Personal Notes", description = "API for user-specific personal notes.")
public class PersonalNoteController {

    static final String PATH_SEGMENT_PERSONAL_NOTES = "/personal-notes";

    public static final String API_PERSONAL_NOTES = ApiDocumentation.DRIVER_URI + ApiDocumentation.DRIVER_VERSION_URI_V1 + PATH_SEGMENT_PERSONAL_NOTES;
    static final String API_PERSONAL_NOTES_KEY = API_PERSONAL_NOTES + "/{key}";

    private static final String OID_CLAIM = "oid";
    private static final String KEY_PATTERN = "[a-zA-Z][a-zA-Z0-9_-]*";

    private final PersonalNoteServiceImpl personalNoteService;

    @GetMapping(API_PERSONAL_NOTES)
    @Operation(summary = "Get all personal notes.", description = "Returns all key/value notes for the authenticated user.")
    @ApiResponse(responseCode = "200", description = "Personal notes found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = PersonalNoteResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getAllPersonalNotes(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        List<PersonalNote> notes = personalNoteService.getAllByOid(oid);
        return ResponseEntityFactory.createOkResponse(new PersonalNoteResponse(notes), requestId);
    }

    @GetMapping(API_PERSONAL_NOTES_KEY)
    @Operation(summary = "Get a personal note by key.", description = "Returns a single note value for the authenticated user by key.")
    @ApiResponse(responseCode = "200", description = "Personal note found.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = PersonalNoteResponse.class)))
    @ApiResponse(responseCode = "404", description = ApiDocumentation.STATUS_404,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = ch.sbb.das.backend.common.Problem.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> getPersonalNote(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable @Size(max = 64) @Pattern(regexp = KEY_PATTERN) String key,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        Optional<PersonalNote> note = personalNoteService.getByOidAndKey(oid, key);
        if (note.isPresent()) {
            return ResponseEntityFactory.createOkResponse(new PersonalNoteResponse(List.of(note.get())), requestId);
        } else {
            return ResponseEntityFactory.createNotFoundResponse(requestId, API_PERSONAL_NOTES + "/" + key);
        }
    }

    @PutMapping(API_PERSONAL_NOTES_KEY)
    @Operation(summary = "Save a personal note.", description = "Creates or updates a note value for the authenticated user. The request body can be any valid JSON.")
    @ApiResponse(responseCode = "200", description = "Personal note saved.",
        content = @Content(mediaType = MediaType.APPLICATION_JSON_VALUE, schema = @Schema(implementation = PersonalNoteResponse.class)))
    @ApiErrorResponses
    public ResponseEntity<? extends Response> savePersonalNote(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable @Size(max = 64) @Pattern(regexp = KEY_PATTERN) String key,
        @RequestBody JsonNode value,
        JwtAuthenticationToken authentication) {
        String oid = authentication.getToken().getClaimAsString(OID_CLAIM);
        PersonalNote saved = personalNoteService.save(oid, key, value);
        return ResponseEntityFactory.createOkResponse(new PersonalNoteResponse(List.of(saved)), requestId);
    }
}

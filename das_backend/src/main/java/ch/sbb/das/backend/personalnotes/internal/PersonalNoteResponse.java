package ch.sbb.das.backend.personalnotes.internal;

import ch.sbb.das.backend.common.ApiResponse;
import java.util.List;

public record PersonalNoteResponse(List<PersonalNote> data) implements ApiResponse<PersonalNote> {

}

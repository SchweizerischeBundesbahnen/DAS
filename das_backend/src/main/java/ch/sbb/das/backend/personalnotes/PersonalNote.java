package ch.sbb.das.backend.personalnotes;

import java.time.LocalDateTime;
import tools.jackson.databind.JsonNode;

public record PersonalNote(String key, JsonNode value, LocalDateTime lastModifiedAt) {
}

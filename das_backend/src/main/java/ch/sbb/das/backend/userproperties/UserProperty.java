package ch.sbb.das.backend.userproperties;

import java.time.LocalDateTime;
import tools.jackson.databind.JsonNode;

public record UserProperty(String key, JsonNode value, LocalDateTime lastModifiedAt) {
}

package ch.sbb.das.backend.personalnotes.internal;

import tools.jackson.databind.JsonNode;

public record PersonalNote(String key, JsonNode value) {

}

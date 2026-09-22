package ch.sbb.das.backend.userproperties.internal;

import tools.jackson.databind.JsonNode;

public record UserProperty(String key, JsonNode value) {

}

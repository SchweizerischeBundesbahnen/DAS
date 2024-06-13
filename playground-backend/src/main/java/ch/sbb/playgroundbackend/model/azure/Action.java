package ch.sbb.playgroundbackend.model.azure;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Action(@JsonProperty("@odata.type") String type, Claims claims) {
}

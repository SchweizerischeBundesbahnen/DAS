package ch.sbb.playgroundbackend.model.azure;

import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.List;

public record TokenIssuanceStartResponseData(@JsonProperty("@odata.type") String type, List<Action> actions) {
}

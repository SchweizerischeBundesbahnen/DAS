package ch.sbb.sferamock.exchange.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Action(@JsonProperty("@odata.type") String type, Claims claims) {
}

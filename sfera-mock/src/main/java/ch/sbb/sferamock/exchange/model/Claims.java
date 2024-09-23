package ch.sbb.sferamock.exchange.model;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Claims(@JsonProperty("ru") String ru,
                     @JsonProperty("train") String train,
                     @JsonProperty("role") String role) {
}

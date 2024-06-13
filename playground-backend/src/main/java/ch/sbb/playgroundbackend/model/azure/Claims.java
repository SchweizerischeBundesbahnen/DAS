package ch.sbb.playgroundbackend.model.azure;

import com.fasterxml.jackson.annotation.JsonProperty;

public record Claims(@JsonProperty("http://uic.org/90940/ru") String ru,
                     @JsonProperty("http://uic.org/90940/train") String train,
                     @JsonProperty("http://uic.org/90940/role") String role) {
}
